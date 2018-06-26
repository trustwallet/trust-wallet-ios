// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import TrustKeystore

protocol WalletInfoViewControllerDelegate: class {
    func didPress(item: WalletInfoType, in controller: WalletInfoViewController)
}

class WalletInfoViewController: FormViewController {

    let wallet: Wallet
    weak var delegate: WalletInfoViewControllerDelegate?

    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.title = viewModel.title
        let types = fieldTypes(for: wallet)

        let section = Section()

        for type in types {
            section.append(link(item: type))
        }

        form +++ section
    }

    func fieldTypes(for wallet: Wallet) -> [WalletInfoType] {
        switch wallet.type {
        case .privateKey(let account):
            return [
                .exportKeystore(account),
                .exportPrivateKey(account),
            ]
        case .hd(let account):
            return [
                .exportRecoveryPhrase(account),
                .exportPrivateKey(account),
                .exportKeystore(account),
            ]
        case .address:
            return []
        }
    }

    private func link(
        item: WalletInfoType
    ) -> ButtonRowRow {
        let button = ButtonRowRow(item.title) {
            $0.title = item.title
            $0.value = item
        }.onCellSelection { [weak self] (_, row) in
            guard let `self` = self, let item = row.value else { return }
            self.delegate?.didPress(item: item, in: self)
        }.cellSetup { cell, _ in
            cell.imageView?.image = item.image
            cell.imageView?.layer.cornerRadius = 6
            cell.imageView?.layer.masksToBounds = true
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        }
        return button
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias ButtonRowRow = ButtonRowOf<WalletInfoType>

