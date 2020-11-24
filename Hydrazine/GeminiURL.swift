import Foundation


public struct GeminiURL {
    public enum ParseError: Error {
        case urlTooLong(String, Int)
        case invalidURL(String)
        case missingHost(String)
        
        public var errorMessage: String {
            switch self {
            case .urlTooLong(let urlString, let byteCount):
                return "URL '\(urlString)' is too long by \(byteCount-1024) bytes"
            case .invalidURL(let urlString):
                return "URL '\(urlString)' is invalid"
            case .missingHost(let urlString):
                return "URL '\(urlString)' is missing the host name"
            }
        }
    }
    
    public let url: URL
    
    private init(url: URL) {
        self.url = url
    }
    
    public static func parse(string: String) -> Result<GeminiURL, ParseError> {
        if let url = URL(string: string) {
            if let host = url.host, !host.isEmpty {
                if url.absoluteString.utf8.count > 1024 {
                    return .failure(.urlTooLong(string, string.utf8.count))
                } else {
                    return .success(GeminiURL(url: url))
                }
            } else {
                return .failure(.missingHost(string))
            }
        } else {
            return .failure(.invalidURL(string))
        }
    }
}
