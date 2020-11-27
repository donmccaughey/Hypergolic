import Foundation
import Hydrazine
import Network


class Delegate: GeminiTransactionDelegate {
    func hasStarted(_ transaction: GeminiTransaction) {
        NSLog("Has started")
    }
    
    func willVerifyTrust(_ transaction: GeminiTransaction,
                         protocolMetadata: sec_protocol_metadata_t,
                         trust: SecTrust)
    {
        NSLog("Will verify trust")
    }
    
    func didVerifyTrust(_ transaction: GeminiTransaction,
                        trust: SecTrust,
                        error: CFError?)
    {
        if let error = error {
            NSLog("Did verify trust with error: \(error)")
        } else {
            NSLog("Did verify trust")
        }
    }
    
    func didFailTrustVerification(_ transaction: GeminiTransaction,
                                  trust: SecTrust,
                                  error: CFError?)
    {
        if let error = error {
            NSLog("Did fail trust verification with error: \(error)")
        } else {
            NSLog("Did fail trust verification")
        }
    }
    
    func willSendRequest(_ transaction: GeminiTransaction,
                         request: GeminiRequest)
    {
        NSLog("Will send request")
        NSLog(">>> \(request.string)")
    }
    
    func willScheduleReceive(_ transaction: GeminiTransaction) {
        NSLog("Will schedule receive")
    }
    
    func didReceiveData(_ transaction: GeminiTransaction,
                        data: Data,
                        isMessageComplete: Bool)
    {
        NSLog("Did receive data: \(data.count) bytes, message is\(isMessageComplete ? " " : " not ")complete")
    }
    
    func receiveDidComplete(_ transaction: GeminiTransaction) {
        NSLog("Receive did complete")
    }
    
    func receiveDidFail(_ transaction: GeminiTransaction, error: NWError) {
        NSLog("Receive did fail: \(error)")
        exit(EXIT_FAILURE)
    }
    
    func didReceiveResponse(_ transaction: GeminiTransaction,
                            response: GeminiResponse)
    {
        NSLog("Did receive response: statusCode: \(response.statusCode), meta: \(response.meta)")
        NSLog("<<< \(response.string)")
        exit(EXIT_SUCCESS)
    }
    
    func didReceiveInvalidResponse(_ transaction: GeminiTransaction,
                                   error: GeminiResponse.ParseError)
    {
        NSLog("Did receive invalid response: \(error.message)")
        exit(EXIT_FAILURE)
    }

    func connectionIsSetup(_ transaction: GeminiTransaction) {
        NSLog("Connection is setup")
    }
    
    func connectionIsWaiting(_ transaction: GeminiTransaction, error: NWError) {
        NSLog("Connection is waiting: \(error)")
        exit(EXIT_FAILURE)
    }
    
    func connectionIsPreparing(_ transaction: GeminiTransaction) {
        NSLog("Connection is preparing")
    }
    
    func connectionIsReady(_ transaction: GeminiTransaction) {
        NSLog("Connection is ready")
    }
    
    func connectionFailed(_ transaction: GeminiTransaction, error: NWError) {
        NSLog("Connection failed: \(error)")
        exit(EXIT_FAILURE)
    }
    
    func connectionCancelled(_ transaction: GeminiTransaction) {
        NSLog("Connection cancelled")
        exit(EXIT_FAILURE)
    }
}
