import XCTest
@testable import Hydrazine


class GeminiResponseTests: XCTestCase {
    func testParseEmpty() {
        let result = GeminiResponse.parse(string: "")
        if case let .failure(.responseTooShort(data)) = result {
            XCTAssertTrue(data.isEmpty)
        } else {
            XCTFail()
        }
    }
    
    func testParseHeaderTooShort() {
        let responseData = "20\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.responseTooShort(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseMissingCRLF() {
        let responseData = "40 Try again later".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.missingResponseHeader(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseHeaderTooLong() {
        var responseString = "40 Try again later"
        responseString = responseString.padding(toLength: 1030, withPad: " ", startingAt: 0)
        responseString.append("\r\n")
        let responseData = responseString.data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.responseHeaderTooLong(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseMissingSpace() {
        let responseData = "40Try-again-later\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.invalidResponseHeader(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseSingleDigitStatusCode() {
        let responseData = "4 Try again later\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.invalidResponseHeader(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseTripleDigitStatusCode() {
        let responseData = "400 Try again later\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.invalidResponseHeader(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseHeaderWithInvalidUTF8() {
        var responseData = "40 Try again later".data(using: .utf8)!
        responseData.append(0xff)
        responseData.append("\r\n".data(using: .utf8)!)
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.invalidUTF8InResponseHeader(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
}


extension GeminiResponse {
    public static func parse(string: String) -> Result<GeminiResponse, ParseError> {
        return parse(data: string.data(using: .utf8)!)
    }
}
