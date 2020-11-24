import Foundation
import Network


public protocol GeminiTransactionDelegate {
    func connectionIsSetup(_ transaction: GeminiTransaction)
    func connectionIsWaiting(_ transaction: GeminiTransaction, error: NWError)
    func connectionIsPreparing(_ transaction: GeminiTransaction)
    func connectionIsReady(_ transaction: GeminiTransaction)
    func connectionFailed(_ transaction: GeminiTransaction, error: NWError)
    func connectionCancelled(_ transaction: GeminiTransaction)
}


public class GeminiTransaction {
    public var delegate: GeminiTransactionDelegate?
    public let queue: DispatchQueue
    public let url: URL
    
    public lazy var connection = createConnection()
    public lazy var host = NWEndpoint.Host(url.host!)
    public lazy var port = NWEndpoint.Port(integerLiteral: UInt16(url.port ?? 1965))
    public lazy var tlsParameters = NWParameters.init(tls: createTLSOptions())
    
    public init(url: URL,
                delegate: GeminiTransactionDelegate? = nil,
                queue: DispatchQueue = DispatchQueue(label: "cc.donm.Hydrazine"))
    {
        self.delegate = delegate
        self.queue = queue
        self.url = url
    }
    
    public func run() {
        NSLog("Starting")
        connection.start(queue: queue)

        NSLog("Sending")
        let requestString = "\(url)\r\n"
        NSLog(">>> \(requestString)")
        let request = requestString.data(using: .utf8)
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
        sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { (sec_protocol_metadata, sec_trust, sec_protocol_verify_complete) in
            NSLog("in sec_protocol_verify_t block")
            
            let secTrust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
            SecTrustSetOptions(secTrust, [.allowExpired, .allowExpiredRoot, .leafIsCA, .implicitAnchors])
            var error: CFError?
            let verified = SecTrustEvaluateWithError(secTrust, &error)
            
            let isVerified: Bool
            if verified {
                NSLog("Verified...")
                isVerified = true
            } else if let error = error {
                // TODO: improve error handling
                let expectedErrors = [-25318, -67609, -67901]
                if expectedErrors.contains(CFErrorGetCode(error)) {
                    NSLog("Expected error: \(error)")
                    isVerified = true
                } else {
                    NSLog("Not verified: \(error)")
                    isVerified = false
                }
            } else {
                NSLog("Not verified")
                isVerified = false
            }
            sec_protocol_verify_complete(isVerified)
        }, queue)
        return tlsOptions
    }

    private func receive() {
        NSLog("Receiving")
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) {
            (data, contentContext, isComplete, error) in
            
            if let data = data, !data.isEmpty {
                if let response = String(data: data, encoding: .utf8) {
                    print("<<< \(response)")
                } else {
                    NSLog("Encoding error in response")
                    exit(EXIT_FAILURE)
                }
            }
            if let contentContext = contentContext, contentContext.isFinal {
                NSLog("Received final content")
                exit(EXIT_SUCCESS);
            }
            if isComplete {
                NSLog("Receive complete")
                exit(EXIT_SUCCESS);
            }
            if let error = error {
                NSLog("Receive error: \(error)")
                exit(EXIT_FAILURE)
            }
            self.receive()
        }
    }
}
