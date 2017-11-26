// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import XCTest
@testable import Trust

class EthereumConverterTests: XCTestCase {
    
    func testEther() {
        let value = BigInt("437258644730000000000")!
        
        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 3)
        
        XCTAssertEqual("437.258", result)
    }
    
    func testEtherSmallNumber() {
        let value = BigInt("1000000000000000")!
        
        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 3)
        
        XCTAssertEqual("0.001", result)
    }

    func testNoDecimals() {
        let value = BigInt("1000000000000000")!

        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 0, maximumFractionDigits: 0)

        XCTAssertEqual("0", result)
    }

    func testNegative() {
        let value = BigInt("-437258644730000000000")!

        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 3)

        XCTAssertEqual("-437.258", result)
    }
    
    func testFraction() {
        let value = BigInt("437258644730000000000")!
        
        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 8, maximumFractionDigits: 8)
        
        XCTAssertEqual("437.25864473", result)
    }
}
