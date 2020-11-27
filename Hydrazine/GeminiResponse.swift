import Foundation


public struct GeminiResponse {
    public static let maxHeaderLength = 1029 // <2 byte status code> + SP + <max 1024 bytes meta> + CR + LF
    public static let metaStartIndex = 3 // first byte past <2 byte status code> + SP
    public static let minResponseLength = 5 // <2 byte status code> + SP + <0 byte meta> + CR + LF
    public static let statusCategories: [UInt] = [1, 2, 3, 4, 5, 6]
    public static let statusCodes: [UInt] = [10, 11, 20, 30, 31, 40, 41, 42, 43, 44, 50, 51, 52, 53, 59, 60, 61, 62]
    
    public enum ParseError: Error {
        case responseTooShort(Data)
        case missingStatusCode(Data)
        case invalidStatusCode(Data, UInt)
        case missingResponseHeader(Data)
        case responseHeaderTooLong(Data)
        case invalidUTF8InResponseHeader(Data)
        
        public var errorMessage: String {
            return "Error parsing response header"
        }
    }
    
    public let statusCode: UInt
    public let meta: String
    public let body: Data?
    
    public var data: Data {
        header.data(using: .utf8)! + (body ?? Data())
    }
    public var header: String {
        "\(statusCode) \(meta)\r\n"
    }
    public var statusCategory: UInt {
        statusCode / 10
    }
    public var string: String {
        String(data: data, encoding: .utf8) ?? (header + String(describing: body))
    }
    
    private init(statusCode: UInt, meta: String, body: Data?) {
        self.statusCode = statusCode
        self.meta = meta
        self.body = body
    }
    
    public static func parse(data: Data) -> Result<GeminiResponse, ParseError> {
        if data.count < minResponseLength {
            return .failure(.responseTooShort(data))
        }
        
        guard data[0].isDigit && data[1].isDigit && data[2].isSpace else {
            return .failure(.missingStatusCode(data))
        }
        
        let statusCode = UInt(String(data: data[0...1], encoding: .utf8)!)!
        guard statusCategories.contains(statusCode / 10) else {
            return .failure(.invalidStatusCode(data, statusCode))
        }
        
        guard let crlfRange = data.range(of: "\r\n".data(using: .utf8)!) else {
            return .failure(.missingResponseHeader(data))
        }
        
        let metaEndIndex = crlfRange.lowerBound
        let headerEndIndex = crlfRange.upperBound
        
        if headerEndIndex >= maxHeaderLength {
            return .failure(.responseHeaderTooLong(data))
        }
        
        guard let meta = String(data: data[metaStartIndex..<metaEndIndex], encoding: .utf8) else {
            return .failure(.invalidUTF8InResponseHeader(data))
        }
        
        let body: Data?
        if data.count > crlfRange.upperBound {
            body = data[crlfRange.upperBound...]
        } else {
            body = nil
        }
        
        return .success(Self(statusCode: statusCode, meta: meta, body: body))
    }
}
