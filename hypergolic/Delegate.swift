import Foundation
import Hydrazine
import Network


class Delegate: GeminiTransactionDelegate {
    func hasStarted(_ transaction: GeminiTransaction) {
        NSLog("Has started")
    }
    
    func willSendRequest(_ transaction: GeminiTransaction) {
        NSLog("Will send request")
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


