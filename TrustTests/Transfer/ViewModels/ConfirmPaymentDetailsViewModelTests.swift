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
        
        let description = session.account.info.name + " " + "(\(session.account.address.description))"
        
        XCTAssertEqual(description, viewModel.currentWalletDescriptionString)
    }
}
