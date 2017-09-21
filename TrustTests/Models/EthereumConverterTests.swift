// Copyright SIX DAY LLC, Inc. All rights reserved.

import XCTest
@testable import Trust

class EthereumConverterTests: XCTestCase {
    
    func testEther() {
        let value = BInt("437258644730000000000")
        
        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 3)
        
        XCTAssertEqual("437.258", result)
    }
    
    func testEtherSmallNumber() {
        let value = BInt("1000000000000000")
        
        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 3)
        
        XCTAssertEqual("0.001", result)
    }
    
    func testFraction() {
        let value = BInt("437258644730000000000")
        
        let result = EthereumConverter.from(value: value, to: .ether, minimumFractionDigits: 8, maximumFractionDigits: 8)
        
        XCTAssertEqual("437.25864473", result)
    }
}
