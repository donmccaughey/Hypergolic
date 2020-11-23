import Foundation


public enum GeminiURLError: Error {
    case urlTooLong(String)
    case invalidURL(String)
    case missingHost(String)
    
    public var errorMessage: String {
        switch self {
        case .urlTooLong(let urlString):
            return "URL '\(urlString)' is too long"
        case .invalidURL(let urlString):
            return "URL '\(urlString)' is invalid"
        case .missingHost(let urlString):
            return "URL '\(urlString)' is missing the host name"
        }
    }
}


public func parseGeminiURL(urlString: String) -> (URL?, GeminiURLError?) {
    if urlString.utf8.count > 1024 {
        return (nil, .urlTooLong(urlString))
    }
    let parsedURL = URL(string: urlString)
    if parsedURL == nil {
        return (nil, .invalidURL(urlString))
    }
    if parsedURL!.host == nil || parsedURL!.host!.isEmpty {
        return (nil, .missingHost(urlString))
    }
    return (parsedURL!, nil)
}
