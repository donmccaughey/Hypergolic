import Foundation


public class GeminiTransaction {
    public let queue: DispatchQueue
    public let url: URL
    
    public init(url: URL) {
        self.queue = DispatchQueue.global()
        self.url = url
    }
}
