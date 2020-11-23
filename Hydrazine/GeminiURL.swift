import Foundation


public enum GeminiURLError: Error {
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


public enum GeminiURL {
    case url(URL)
    case error(GeminiURLError)
    
    public static func parse(urlString: String) -> GeminiURL {
        if urlString.utf8.count > 1024 {
            return .error(.urlTooLong(urlString, urlString.utf8.count))
        }
        let parsedURL = URL(string: urlString)
        if parsedURL == nil {
            return .error(.invalidURL(urlString))
        }
        if parsedURL!.host == nil || parsedURL!.host!.isEmpty {
            return .error(.missingHost(urlString))
        }
        return .url(parsedURL!)
    }
}
