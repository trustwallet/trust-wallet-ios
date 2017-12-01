// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BackupViewControllerDelegate: class {
    func didPressBackup(account: Account, in viewController: BackupViewController)
    func didPressLater(account: Account, in viewController: BackupViewController)
}

class BackupViewController: UIViewController {

    let account: Account
    weak var delegate: BackupViewControllerDelegate?
    let viewModel = BackupViewModel()

    init(account: Account) {
        self.account = account

        super.init(nibName: nil, bundle: nil)

        let warningImageView = UIImageView()
        warningImageView.translatesAutoresizingMaskIntoConstraints = false
        warningImageView.image = R.image.backup_warning()

        let noBackupLabel = UILabel()
        noBackupLabel.translatesAutoresizingMaskIntoConstraints = false
        noBackupLabel.text = viewModel.headlineText
        noBackupLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        noBackupLabel.adjustsFontSizeToFitWidth = true
        noBackupLabel.textColor = Colors.lightBlack

        let controlMoneyLabel = UILabel()
        controlMoneyLabel.translatesAutoresizingMaskIntoConstraints = false
        controlMoneyLabel.text = NSLocalizedString("export.controlYourMoney.title", value: "Since only you control your money, you'll need to save your backup keystore in case this app is deleted.", comment: "")
        controlMoneyLabel.numberOfLines = 0
        controlMoneyLabel.textAlignment = .center
        controlMoneyLabel.textColor = Colors.darkGray

        let neverStoredLabel = UILabel()
        neverStoredLabel.translatesAutoresizingMaskIntoConstraints = false
        neverStoredLabel.text = NSLocalizedString("export.neverStored.title", value: "Your wallet is never saved to cloud storage or standard device backups.", comment: "")
        neverStoredLabel.numberOfLines = 0
        neverStoredLabel.textAlignment = .center
        neverStoredLabel.textColor = Colors.darkGray

        let backupButton = Button(size: .large, style: .solid)
        backupButton.translatesAutoresizingMaskIntoConstraints = false
        backupButton.setTitle(NSLocalizedString("export.backupButton.title", value: "Backup Wallet", comment: ""), for: .normal)
        backupButton.addTarget(self, action: #selector(backup), for: .touchUpInside)

        let doItLaterButton = Button(size: .large, style: .border)
        doItLaterButton.translatesAutoresizingMaskIntoConstraints = false
        doItLaterButton.setTitle(NSLocalizedString("export.doItLater.title", value: "Do it later", comment: ""), for: .normal)
        doItLaterButton.addTarget(self, action: #selector(later), for: .touchUpInside)

        let stackView = UIStackView(
            arrangedSubviews: [
                warningImageView,
                .spacer(),
                noBackupLabel,
                .spacer(height: 15),
                controlMoneyLabel,
                neverStoredLabel,
                .spacer(height: 15),
                backupButton,
                doItLaterButton,
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .white
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.layoutGuide.leadingAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: view.layoutGuide.trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutGuide.bottomAnchor, constant: -StyleLayout.sideMargin),

            backupButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            backupButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            doItLaterButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            doItLaterButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }

    @objc func backup() {
        delegate?.didPressBackup(account: account, in: self)
    }

    @objc func later() {
        delegate?.didPressLater(account: account, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
