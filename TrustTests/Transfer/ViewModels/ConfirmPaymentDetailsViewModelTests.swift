// Copyright DApps Platform Inc. All rights reserved.

import XCTest
import Realm
import RealmSwift
import BigInt
@testable import Trust
import TrustCore

class ConfirmPaymentDetailsViewModelTests: XCTestCase {

    func testActionButtonTitleOnSignAndSend() {
        let transactionAddress = EthereumAddress(string: "0x000000000000000000000000000000000000003c")!
        let transaction: PreviewTransaction = .make(account: .make(address: transactionAddress))
        let session: WalletSession = .make()
        let viewModel = ConfirmPaymentDetailsViewModel(
            transaction: transaction,
            session: session,
            server: .make()
        )
        let address = transaction.account.address.description
        let infoViewModel = WalletInfoViewModel(wallet: session.account)
        let description = infoViewModel.name + " " + "(\(address.prefix(10))...\(address.suffix(8)))"

        XCTAssertEqual(description, viewModel.currentWalletDescriptionString)
    }
}
