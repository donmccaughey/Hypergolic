import Foundation
import Network


public class GeminiTransaction {
    public var delegate: GeminiTransactionDelegate?
    public let request: GeminiRequest
    public let queue: DispatchQueue
    
    private lazy var connection = createConnection()
    private lazy var host = NWEndpoint.Host(url.host!)
    private lazy var port = NWEndpoint.Port(integerLiteral: UInt16(url.port ?? 1965))
    private lazy var tlsParameters = NWParameters.init(tls: createTLSOptions())
    
    public var geminiURL: GeminiURL {
        request.geminiURL
    }
    public var url: URL {
        request.url
    }
    
    public init(geminiURL: GeminiURL,
                delegate: GeminiTransactionDelegate? = nil,
                queue: DispatchQueue = DispatchQueue(label: "cc.donm.Hydrazine.GeminiTransaction"))
    {
        self.delegate = delegate
        self.request = GeminiRequest(geminiURL: geminiURL)
        self.queue = queue
    }
    
    public func run() {
        delegate?.hasStarted(self)
        connection.start(queue: queue)
        delegate?.willSendRequest(self, request: request)
        connection.send(content: request.data, completion: .idempotent)
        receive(buffer: Data())
    }
    
    private func createConnection() -> NWConnection {
        let connection = NWConnection(host: host, port: port, using: tlsParameters)
        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .setup:
                self.delegate?.connectionIsSetup(self)
            case .waiting(let error):
                self.delegate?.connectionIsWaiting(self, error: error)
            case .preparing:
                self.delegate?.connectionIsPreparing(self)
            case .ready:
                self.delegate?.connectionIsReady(self)
            case .failed(let error):
                self.delegate?.connectionFailed(self, error: error)
            case .cancelled:
                self.delegate?.connectionCancelled(self)
            @unknown default:
                fatalError()
            }
        }
        return connection
    }
    
    private func createTLSOptions() -> NWProtocolTLS.Options {
        let tlsOptions = NWProtocolTLS.Options()
        let securityProtocolOptions = tlsOptions.securityProtocolOptions
        // TODO: configure securityProtocolOptions
        sec_protocol_options_set_verify_block(securityProtocolOptions, {
            (sec_protocol_metadata, sec_trust, sec_protocol_verify_complete) in
            
            let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
            let isVerified = self.verifyTrust(protocolMetadata: sec_protocol_metadata,
                                              trust: trust)
            sec_protocol_verify_complete(isVerified)
        }, queue)
        return tlsOptions
    }
    
    private func onReceive(buffer: Data,
                           data: Data?,
                           contentContext: NWConnection.ContentContext?,
                           isMessageComplete: Bool,
                           error: NWError?)
    {
        if let error = error {
            delegate?.receiveDidFail(self, error: error)
            return
        }
        if let data = data {
            delegate?.didReceiveData(self, data: data, isMessageComplete: isMessageComplete)
            if isMessageComplete {
                
            } else {
                receive(buffer: buffer + data)
            }
        } else {
            delegate?.receiveDidComplete(self)
        }
    }
    
    private func receive(buffer: Data) {
        delegate?.willScheduleReceive(self)
        connection.receive(minimumIncompleteLength: 1024, maximumLength: 64 * 1024) {
            (data, contentContext, isMessageComplete, error) in
            
            self.onReceive(buffer: buffer,
                           data: data,
                           contentContext: contentContext,
                           isMessageComplete: isMessageComplete,
                           error: error)
        }
    }
    
    private func verifyTrust(protocolMetadata: sec_protocol_metadata_t,
                             trust: SecTrust) -> Bool
    {
        delegate?.willVerifyTrust(self,
                                  protocolMetadata: protocolMetadata,
                                  trust: trust)
        
        SecTrustSetOptions(trust, [.allowExpired, .allowExpiredRoot, .leafIsCA, .implicitAnchors])
        var error: CFError?
        let verified = SecTrustEvaluateWithError(trust, &error)
        
        let isVerified: Bool
        if verified {
            delegate?.didVerifyTrust(self, trust: trust, error: nil)
            isVerified = true
        } else if let error = error {
            // TODO: improve error handling
            let expectedErrors = [-25318, -67609, -67901]
            if expectedErrors.contains(CFErrorGetCode(error)) {
                delegate?.didVerifyTrust(self, trust: trust, error: error)
                isVerified = true
            } else {
                delegate?.didFailTrustVerification(self, trust: trust, error: error)
                isVerified = false
            }
        } else {
            delegate?.didFailTrustVerification(self, trust: trust, error: nil)
            isVerified = false
        }
        return isVerified
    }
}
