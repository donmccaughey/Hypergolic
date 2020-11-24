import XCTest
@testable import Hydrazine


class GeminiURLTests: XCTestCase {
    func testValidURL() {
        let urlString = "gemini://foo.example.com/"
        let result = GeminiURL.parse(string: urlString)
        if case let .success(geminiURL) = result {
            XCTAssertEqual(urlString, geminiURL.url.absoluteString)
        } else {
            XCTFail()
        }
    }
    
    func testURLTooLong() throws {
        var urlString = "gemini://foo.example.com/"
        for _ in 0..<256 {
            urlString.append("bar/")
        }
        assert(urlString.utf8.count > 1024)
        
        let geminiURL = GeminiURL.parse(string: urlString)
        if case let .failure(.urlTooLong(sameURLString, count)) = geminiURL {
            XCTAssertEqual(urlString, sameURLString)
            XCTAssertEqual(urlString.utf8.count, count)
        } else {
            XCTFail()
        }
    }
    
    func testInvalidURL() throws {
        let urlString = ""
        let geminiURL = GeminiURL.parse(string: urlString)
        if case let .failure(.invalidURL(sameURLString)) = geminiURL {
            XCTAssertEqual(urlString, sameURLString)
        } else {
            XCTFail()
        }
    }
    
    func testMissingHost() throws {
        let urlString = "gemini:///foo/bar/"
        let geminiURL = GeminiURL.parse(string: urlString)
        if case let .failure(.missingHost(sameURLString)) = geminiURL {
            XCTAssertEqual(urlString, sameURLString)
        } else {
            XCTFail()
        }
    }
}
