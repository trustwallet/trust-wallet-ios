// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import BigInt

class TransactionConfiguratorTests: XCTestCase {

    func testDefault() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasLimit: BigInt(90000), gasPrice: .none))
        
        XCTAssertEqual(GasPriceConfiguration.default, configurator.configuration.gasPrice)
        XCTAssertEqual(GasLimitConfiguration.default, configurator.configuration.gasLimit)
    }
    
    func testAdjustGasPrice() {
        let desiderGasPrice = BigInt(2000000000)
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: desiderGasPrice))
        
        XCTAssertEqual(desiderGasPrice, configurator.configuration.gasPrice)
    }
    
    func testMinGasPrice() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: BigInt(1)))
        
        XCTAssertEqual(GasPriceConfiguration.min, configurator.configuration.gasPrice)
    }
    
    func testMaxGasPrice() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasPrice: BigInt(990000000000)))
        
        XCTAssertEqual(GasPriceConfiguration.max, configurator.configuration.gasPrice)
    }
    
    func testLoadEtherConfiguration() {
        let configurator = TransactionConfigurator(session: .make(), account: .make(), transaction: .make(gasLimit: BigInt(90000), gasPrice: .none))

        configurator.load { _ in }
        
        XCTAssertEqual(BigInt(GasPriceConfiguration.default), configurator.configuration.gasPrice)
        XCTAssertEqual(BigInt(90000), configurator.configuration.gasLimit)
    }
}
