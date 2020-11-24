import Foundation
import Network


public class GeminiTransaction {
    public var delegate: GeminiTransactionDelegate?
    public let queue: DispatchQueue
    public let url: URL
    
    private lazy var connection = createConnection()
    private lazy var host = NWEndpoint.Host(url.host!)
    private lazy var port = NWEndpoint.Port(integerLiteral: UInt16(url.port ?? 1965))
    private lazy var tlsParameters = NWParameters.init(tls: createTLSOptions())
    
    public init(url: URL,
                delegate: GeminiTransactionDelegate? = nil,
                queue: DispatchQueue = DispatchQueue(label: "cc.donm.Hydrazine.GeminiTransaction"))
    {
        self.delegate = delegate
        self.queue = queue
        self.url = url
    }
    
    public func run() {
        delegate?.hasStarted(self)
        connection.start(queue: queue)

        let requestString = "\(url)\r\n"
        let request = requestString.data(using: .utf8)!
        delegate?.willSendRequest(self, request: request)
        connection.send(content: request, completion: .idempotent)
        receive()
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
            [self] (sec_protocol_metadata, sec_trust, sec_protocol_verify_complete) in
            
            let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
            let isVerified = self.verifyTrust(protocolMetadata: sec_protocol_metadata,
                                              trust: trust)
            sec_protocol_verify_complete(isVerified)
        }, queue)
        return tlsOptions
    }

    private func receive() {
        delegate?.willScheduleReceive(self)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) {
            [self] (data, contentContext, isComplete, error) in
            
            if let data = data, !data.isEmpty {
                delegate?.didReceiveData(self, data: data)
            }
            if let contentContext = contentContext, contentContext.isFinal {
                delegate?.didReceiveFinalMessage(self)
            }
            if isComplete {
                delegate?.receiveDidComplete(self)
            }
            if let error = error {
                delegate?.receiveDidFail(self, error: error)
            }
            self.receive()
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
