import XCTest
@testable import Hydrazine


class GeminiResponseTests: XCTestCase {
    func testParseEmpty() {
        let result = GeminiResponse.parse(data: "".data(using: .utf8)!)
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
    
    func testParseMissingStatusCode() {
        let responseData = "text/gemini\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.missingStatusCode(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseMissingSpace() {
        let responseData = "20text/gemini\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.missingStatusCode(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }
    
    func testParseSingleDigitStatusCode() {
        let responseData = "2 text/gemini\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.missingStatusCode(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }

    func testParseTripleDigitStatusCode() {
        let responseData = "200 text/gemini\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.missingStatusCode(data)) = result {
            XCTAssertEqual(data, responseData)
        } else {
            XCTFail()
        }
    }

    func testParseInvalidStatusCode() {
        let responseData = "90 I'm a teapot\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.invalidStatusCode(data, statusCode)) = result {
            XCTAssertEqual(data, responseData)
            XCTAssertEqual(90, statusCode)
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
        responseString = responseString.padding(toLength: GeminiResponse.maxHeaderLength, withPad: " ", startingAt: 0)
        responseString.append("\r\n")
        let responseData = responseString.data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .failure(.responseHeaderTooLong(data)) = result {
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

    func testParseSuccessNoBody() {
        let responseData = "40 Try again later\r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .success(response) = result {
            XCTAssertEqual(40, response.statusCode)
            XCTAssertEqual(4, response.statusCategory)
            XCTAssertEqual("Try again later", response.meta)
            XCTAssertNil(response.body)
        } else {
            XCTFail()
        }
    }

    func testParseSuccessNoMetaNoBody() {
        let responseData = "40 \r\n".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .success(response) = result {
            XCTAssertEqual(40, response.statusCode)
            XCTAssertEqual(4, response.statusCategory)
            XCTAssertEqual("", response.meta)
            XCTAssertNil(response.body)
        } else {
            XCTFail()
        }
    }

    func testParseSuccessWithBody() {
        let responseData = "20 text/gemini\r\nThis is an example body".data(using: .utf8)!
        let result = GeminiResponse.parse(data: responseData)
        if case let .success(response) = result {
            XCTAssertEqual(20, response.statusCode)
            XCTAssertEqual(2, response.statusCategory)
            XCTAssertEqual("text/gemini", response.meta)
            XCTAssertNotNil(response.body)
            XCTAssertEqual("This is an example body", String(data: response.body!, encoding: .utf8))
        } else {
            XCTFail()
        }
    }
}
