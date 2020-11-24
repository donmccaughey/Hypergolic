import Foundation
import Network


public class GeminiTransaction {
    public let queue: DispatchQueue
    public let url: URL
    
    public lazy var tlsParameters = NWParameters.init(tls: getCustomTLSOptions())
    
    public init(url: URL) {
        self.queue = DispatchQueue.global()
        self.url = url
    }
    
    private func getCustomTLSOptions() -> NWProtocolTLS.Options {
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
}
