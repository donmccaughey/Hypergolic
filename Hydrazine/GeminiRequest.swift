import Foundation


public struct GeminiRequest {
    public let geminiURL: GeminiURL
    
    public var data: Data {
        string.data(using: .utf8)!
    }
    public var string: String {
        "\(url.absoluteString)\r\n"
    }
    public var url: URL {
        geminiURL.url
    }
    
    public init(geminiURL: GeminiURL) {
        self.geminiURL = geminiURL
    }
}
