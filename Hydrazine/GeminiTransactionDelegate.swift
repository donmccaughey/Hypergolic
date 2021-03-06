import Foundation
import Network


public protocol GeminiTransactionDelegate {
    func hasStarted(_ transaction: GeminiTransaction)
    
    func willVerifyTrust(_ transaction: GeminiTransaction,
                         protocolMetadata: sec_protocol_metadata_t,
                         trust: SecTrust)
    func didVerifyTrust(_ transaction: GeminiTransaction,
                        trust: SecTrust,
                        error: CFError?)
    func didFailTrustVerification(_ transaction: GeminiTransaction,
                                  trust: SecTrust,
                                  error: CFError?)

    func willSendRequest(_ transaction: GeminiTransaction,
                         request: GeminiRequest)
    
    func willScheduleReceive(_ transaction: GeminiTransaction)
    func didReceiveData(_ transaction: GeminiTransaction,
                        data: Data,
                        isMessageComplete: Bool)
    func receiveDidComplete(_ transaction: GeminiTransaction)
    func receiveDidFail(_ transaction: GeminiTransaction, error: NWError)
    
    func didReceiveResponse(_ transaction: GeminiTransaction,
                            response: GeminiResponse)
    func didReceiveInvalidResponse(_ transaction: GeminiTransaction,
                                   error: GeminiResponse.ParseError)
    
    func connectionIsSetup(_ transaction: GeminiTransaction)
    func connectionIsWaiting(_ transaction: GeminiTransaction, error: NWError)
    func connectionIsPreparing(_ transaction: GeminiTransaction)
    func connectionIsReady(_ transaction: GeminiTransaction)
    func connectionFailed(_ transaction: GeminiTransaction, error: NWError)
    func connectionCancelled(_ transaction: GeminiTransaction)
}
