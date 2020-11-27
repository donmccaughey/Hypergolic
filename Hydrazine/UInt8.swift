import Foundation


extension UInt8 {
    var isDigit: Bool {
        return self >= 0x30 && self <= 0x39
    }
    
    var isSpace: Bool {
        return self == 0x20
    }
}
