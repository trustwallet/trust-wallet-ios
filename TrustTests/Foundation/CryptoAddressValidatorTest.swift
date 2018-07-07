// Copyright DApps Platform Inc. All rights reserved.

@testable import Trust
import XCTest

class CryptoAddressValidatorTest: XCTestCase {
    func testValidUpperCaseEthAddress() {
        XCTAssertEqual(true, CryptoAddressValidator.isValidAddress("0x5E31A998dA1c1371FA7dC80dA50EBC500F59094f"))
    }
    func testValidLoverCaseEthAddress() {
        XCTAssertEqual(true, CryptoAddressValidator.isValidAddress("0xfa52274dd61e1643d2205169732f29114bc240b3"))
    }
    func testInvalidEthAddresses() {
        XCTAssertEqual(false, CryptoAddressValidator.isValidAddress("0x0000000000000000000000000000000000000009x"))
        XCTAssertEqual(false, CryptoAddressValidator.isValidAddress("1"))
        XCTAssertEqual(false, CryptoAddressValidator.isValidAddress(nil))
        XCTAssertEqual(false, CryptoAddressValidator.isValidAddress("1HB5XMLmzFVj8ALj6mfBsbifRoD4miY36v"))
    }
}
