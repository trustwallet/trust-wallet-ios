// Copyright DApps Platform Inc. All rights reserved.

import Foundation

import UIKit
import Eureka
import MessageUI

protocol AboutViewControllerDelegate: class {
    func didPressURL(_ url: URL, in controller: AboutViewController)
}

final class AboutViewController: FormViewController {

    let viewModel = AboutViewModel()
    weak var delegate: AboutViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

            <<< link(
                title: NSLocalizedString("settings.sourceCode.button.title", value: "Source Code", comment: ""),
                value: "https://github.com/TrustWallet/trust-wallet-ios",
                image: R.image.settings_colorful_source_code()
            )

            <<< link(
                title: NSLocalizedString("settings.reportBug.button.title", value: "Report a Bug", comment: ""),
                value: "https://github.com/TrustWallet/trust-wallet-ios/issues/new",
                image: R.image.settings_colorful_report_a_bug()
            )

            +++ Section(R.string.localizable.poweredBy())

            <<< link(
                title: NSLocalizedString("Infura", value: "Infura", comment: ""),
                value: "https://infura.io/",
                image: R.image.infura()

            )

            <<< link(
                title: NSLocalizedString("OpenSea", value: "OpenSea", comment: ""),
                value: Constants.dappsOpenSea,
                image: R.image.opensea()
            )
    }

    private func link(
        title: String,
        value: String,
        image: UIImage?
    ) -> ButtonRow {
        return AppFormAppearance.button {
            $0.title = title
            $0.value = value
        }.onCellSelection { [weak self] (_, row) in
            guard let `self` = self, let value = row.value, let url = URL(string: value) else { return }
            self.delegate?.didPressURL(url, in: self)
        }.cellSetup { cell, _ in
            cell.imageView?.image = image
            cell.imageView?.layer.cornerRadius = 6
            cell.imageView?.layer.masksToBounds = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
