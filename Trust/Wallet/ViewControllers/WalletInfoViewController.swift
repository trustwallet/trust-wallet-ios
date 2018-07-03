// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import TrustKeystore

protocol WalletInfoViewControllerDelegate: class {
    func didPress(item: WalletInfoType, in controller: WalletInfoViewController)
}

class WalletInfoViewController: FormViewController {

    lazy var viewModel: WalletInfoViewModel = {
        return WalletInfoViewModel(wallet: wallet)
    }()
    let wallet: WalletInfo
    let storage: WalletStorage

    weak var delegate: WalletInfoViewControllerDelegate?

    private struct Values {
        static let name = "name"
    }

    init(
        wallet: WalletInfo,
        storage: WalletStorage
    ) {
        self.wallet = wallet
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        let types = viewModel.types
        let section = Section(footer: viewModel.wallet.wallet.address.description)
        for type in types {
            section.append(link(item: type))
        }

        form +++ section
// TODO: Enable name field
//            <<< AppFormAppearance.textFieldFloat(tag: Values.name) {
//                $0.add(rule: RuleRequired())
//            }.cellUpdate { [weak self] cell, _ in
//                cell.textField.placeholder = self?.viewModel.nameTitle
//                cell.textField.rightViewMode = .always
//            }
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
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
            cell.accessoryType = .disclosureIndicator
        }
        return button
    }

    func save() {
        //wallet.info.name = "Hello"
        //storage.store(objects: [wallet.info])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias ButtonRowRow = ButtonRowOf<WalletInfoType>
