import Foundation
import Network


public protocol GeminiTransactionDelegate {
    func hasStarted(_ transaction: GeminiTransaction)
    func willSendRequest(_ transaction: GeminiTransaction)
    func connectionIsSetup(_ transaction: GeminiTransaction)
    func connectionIsWaiting(_ transaction: GeminiTransaction, error: NWError)
    func connectionIsPreparing(_ transaction: GeminiTransaction)
    func connectionIsReady(_ transaction: GeminiTransaction)
    func connectionFailed(_ transaction: GeminiTransaction, error: NWError)
    func connectionCancelled(_ transaction: GeminiTransaction)
}
