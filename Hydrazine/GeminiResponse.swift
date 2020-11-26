import Foundation


struct GeminiResponse {
    public static let maxHeaderLength = 1029 // <2 byte status code> + SP + <1024 bytes meta> + CR + LF
    public enum ParseError: Error {
        case responseTooShort(Data)
        case missingResponseHeader(Data)
        case responseHeaderTooLong(Data)
        case invalidResponseHeader(Data)
        case invalidUTF8InResponseHeader(Data)
        case invalidStatusCode(String, UInt)
        
        public var errorMessage: String {
            return "Error parsing response header"
        }
    }
    
    public let statusCode: UInt
    public let meta: String
    public let body: Data?
    
    private init(statusCode: UInt, meta: String, body: Data?) {
        self.statusCode = statusCode
        self.meta = meta
        self.body = body
    }
    
    public static func parse(data: Data) -> Result<GeminiResponse, ParseError> {
        if data.count < 5 {
            return .failure(.responseTooShort(data))
        }
        guard let crlfRange = data.range(of: "\r\n".data(using: .utf8)!) else {
            return .failure(.missingResponseHeader(data))
        }
        if crlfRange.upperBound >= maxHeaderLength {
            return .failure(.responseHeaderTooLong(data))
        }
        let headerData = data[0..<crlfRange.upperBound]
        guard let spIndex = headerData.firstIndex(of: 0x20), spIndex == 2 else {
            return .failure(.invalidResponseHeader(headerData))
        }
        guard let header = String(data: headerData, encoding: .utf8) else {
            return .failure(.invalidUTF8InResponseHeader(data))
        }
        
        
        return .failure(.invalidStatusCode("", 0))
    }
}
