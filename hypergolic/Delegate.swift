import Foundation
import Hydrazine
import Network


class Delegate: GeminiTransactionDelegate {
    func connectionIsSetup(_ transaction: GeminiTransaction) {
        NSLog("Setup")
    }
    
    func connectionIsWaiting(_ transaction: GeminiTransaction, error: NWError) {
        NSLog("Waiting: \(error)")
        exit(EXIT_FAILURE)
    }
    
    func connectionIsPreparing(_ transaction: GeminiTransaction) {
        NSLog("Preparing")
    }
    
    func connectionIsReady(_ transaction: GeminiTransaction) {
        NSLog("Ready")
    }
    
    func connectionFailed(_ transaction: GeminiTransaction, error: NWError) {
        NSLog("Failed: \(error)")
        exit(EXIT_FAILURE)
    }
    
    func connectionCancelled(_ transaction: GeminiTransaction) {
        NSLog("Cancelled")
        exit(EXIT_FAILURE)
    }
}


