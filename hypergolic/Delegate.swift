import Foundation
import Hydrazine
import Network


class Delegate: GeminiTransactionDelegate {
    func hasStarted(_ transaction: GeminiTransaction) {
        NSLog("Has started")
    }
    
    func willSendRequest(_ transaction: GeminiTransaction, request: Data) {
        NSLog("Will send request")
        // TODO: temporary logging for request data below
        let requestString = String(data: request, encoding: .utf8)!
        NSLog(">>> \(requestString)")
    }
    
    func willScheduleReceive(_ transaction: GeminiTransaction) {
        NSLog("Will schedule receive")
    }
    
    func didReceiveData(_ transaction: GeminiTransaction, data: Data) {
        NSLog("Did receive data (\(data.count) bytes)")
        // TODO: temporary logging for response data below
        let responseString = String(data: data, encoding: .utf8)!
        print("<<< \(responseString)")
    }
    
    func didReceiveFinalMessage(_ transaction: GeminiTransaction) {
        NSLog("Did receive final message")
        exit(EXIT_SUCCESS);
    }
    
    func receiveDidComplete(_ transaction: GeminiTransaction) {
        NSLog("Receive did complete")
        exit(EXIT_SUCCESS);
    }
    
    func receiveDidFail(_ transaction: GeminiTransaction, error: NWError) {
        NSLog("Receive error: \(error)")
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
