import XCTest
@testable import Hydrazine


class UInt8Tests: XCTestCase {
    func testIsDigit() {
        XCTAssertFalse(UInt8(0x2f).isDigit)
        
        XCTAssertTrue(UInt8(0x30).isDigit)
        XCTAssertTrue(UInt8(0x31).isDigit)
        XCTAssertTrue(UInt8(0x32).isDigit)
        XCTAssertTrue(UInt8(0x33).isDigit)
        XCTAssertTrue(UInt8(0x34).isDigit)
        XCTAssertTrue(UInt8(0x35).isDigit)
        XCTAssertTrue(UInt8(0x36).isDigit)
        XCTAssertTrue(UInt8(0x37).isDigit)
        XCTAssertTrue(UInt8(0x38).isDigit)
        XCTAssertTrue(UInt8(0x39).isDigit)
        
        XCTAssertFalse(UInt8(0x3a).isDigit)
    }
    
    func testIsSapce() {
        XCTAssertFalse(UInt8(0x09).isSpace)
        XCTAssertFalse(UInt8(0x0a).isSpace)
        XCTAssertFalse(UInt8(0x0d).isSpace)
        
        XCTAssertTrue(UInt8(0x20).isSpace)
    }
}
