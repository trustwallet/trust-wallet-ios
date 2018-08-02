// Copyright DApps Platform Inc. All rights reserved.

import XCTest
import Realm
import RealmSwift
import BigInt
@testable import Trust

class ConfirmPaymentDetailsViewModelTests: XCTestCase {

    func testActionButtonTitleOnSignAndSend() {
        let bigInt = BigInt("11274902618710000000000")!
        
        let transaction = PreviewTransaction(
            value: bigInt,
            account: .make(),
            address: .make(),
            contract: .make(),
            nonce: bigInt,
            data: Data(),
            gasPrice: bigInt,
            gasLimit: bigInt,
            transfer: .init(server: .make(), type: .ether(.make(), destination: .none))
        )
        
        let session = WalletSession.make(realm: .make(), sharedRealm: .make())
        
        let viewModel = ConfirmPaymentDetailsViewModel(
            transaction: transaction,
            session: session,
            server: .make()
        )
        
        let description = session.account.info.name + " " + "(\(session.account.address.description))"
        
        XCTAssertEqual(description, viewModel.currentWalletDescriptionString)
    }

}
