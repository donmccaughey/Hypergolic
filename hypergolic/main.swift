import Foundation
import Network
import Hydrazine


let transaction = GeminiTransaction()

let url: URL
if CommandLine.arguments.count > 1 {
    let arg1 = CommandLine.arguments[1]
    let arg1URL = URL(string: arg1)
    if arg1URL == nil {
        NSLog("Invalid URL: '\(arg1)'")
        exit(EXIT_FAILURE)
    }
    if arg1URL!.host == nil || arg1URL!.host!.isEmpty {
        NSLog("Missing host: '\(arg1)'")
        exit(EXIT_FAILURE)
    }
    url = arg1URL!
} else {
    url = URL(string: "gemini://gemini.circumlunar.space/")!
}
NSLog("URL: \(url)")
NSLog("Host: \(url.host!)")
NSLog("Port: \(url.port ?? 1965)")


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
}, DispatchQueue.main)

let tlsParameters = NWParameters.init(tls: tlsOptions)


let host = NWEndpoint.Host(url.host!)
let port = NWEndpoint.Port(integerLiteral: UInt16(url.port ?? 1965))

let connection = NWConnection(host:host, port:port, using: tlsParameters)
connection.stateUpdateHandler = { (newState) in
    switch (newState) {
    case .setup:
        NSLog("Setup")
    case .waiting(let error):
        NSLog("Waiting: \(error)")
        exit(EXIT_FAILURE)
    case .preparing:
        NSLog("Preparing")
    case .ready:
        break
    case .failed(let error):
        NSLog("Failed: \(error)")
        exit(EXIT_FAILURE)
    case .cancelled:
        NSLog("Cancelled")
        exit(EXIT_FAILURE)
    @unknown default:
        fatalError()
    }
}

NSLog("Starting")
connection.start(queue: DispatchQueue.main)

NSLog("Sending")
let requestString = "\(url)\r\n"
NSLog(">>> \(requestString)")
let request = requestString.data(using: .utf8)
connection.send(content: request, completion: .idempotent)

func receive() {
    NSLog("Receiving")
    connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { (data, contentContext, isComplete, error) in
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
        receive()
    }
}
receive()

RunLoop.current.run()
