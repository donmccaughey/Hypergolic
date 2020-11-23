import XCTest
@testable import Hydrazine


class GeminiURLTests: XCTestCase {
    func testURLTooLong() throws {
        var urlString = "gemini://foo.example.com/"
        for _ in 0..<256 {
            urlString.append("bar/")
        }
        XCTAssertTrue(urlString.utf8.count > 1024)
        
        let geminiURL = GeminiURL.parse(urlString: urlString)
        switch geminiURL {
        case .error(let error):
            switch error {
            case let .urlTooLong(sameURLString, count):
                XCTAssertEqual(urlString, sameURLString)
                XCTAssertEqual(urlString.utf8.count, count)
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }
}
