// Copyright DApps Platform Inc. All rights reserved.

import XCTest
import Realm
import RealmSwift
import BigInt
@testable import Trust
import TrustCore

class ConfirmPaymentDetailsViewModelTests: XCTestCase {

    func testActionButtonTitleOnSignAndSend() {
        
        let transaction: PreviewTransaction = .make(address: EthereumAddress.zero)
        let session: WalletSession = .make()
        let viewModel = ConfirmPaymentDetailsViewModel(
            transaction: transaction,
            session: session,
            server: .make()
        )
        let address = session.account.address.description
        let description = session.account.info.name + " " + "(\(address.prefix(10))...\(address.suffix(8)))"

        XCTAssertEqual(description, viewModel.currentWalletDescriptionString)
    }
}
