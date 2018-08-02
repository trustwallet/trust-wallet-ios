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

            <<< linkProvider(type: .sourceCode)

            +++ Section()

            <<< linkProvider(type: .privacyPolicy)
            <<< linkProvider(type: .termsOfService)

            +++ Section()

            <<< AppFormAppearance.button { button in
                button.title = R.string.localizable.settingsEmailUsButtonTitle()
            }.onCellSelection { [weak self] _, _  in
                self?.sendUsEmail()
            }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .disclosureIndicator
                    cell.textLabel?.textAlignment = .left
                    cell.textLabel?.textColor = .black
            })

            +++ Section()

            <<< TextRow {
                $0.title = R.string.localizable.settingsVersionLabelTitle()
                $0.value = Bundle.main.fullVersion
                $0.disabled = true
            }

            +++ Section(R.string.localizable.poweredBy())

            <<< linkProvider(type: .infura)
            <<< linkProvider(type: .dappsOpenSea)
    }

    private func linkProvider(
        type: URLServiceProvider
    ) -> ButtonRow {
        return AppFormAppearance.button {
            $0.title = type.title
        }.onCellSelection { [weak self] (_, _) in
            guard let `self` = self else { return }
            self.delegate?.didPressURL(type.remoteURL, in: self)
        }.cellUpdate({ (cell, _) in
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = .black
        })
    }

    func sendUsEmail() {
        let composerController = MFMailComposeViewController()
        composerController.mailComposeDelegate = self
        composerController.setToRecipients([Constants.supportEmail])
        composerController.setSubject(R.string.localizable.settingsFeedbackEmailTitle())
        composerController.setMessageBody(emailTemplate(), isHTML: false)

        if MFMailComposeViewController.canSendMail() {
            present(composerController, animated: true, completion: nil)
        }
    }

    private func emailTemplate() -> String {
        return """
        \n\n\n

        Helpful information to developers:
        iOS Version: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.model)
        Trust Version: \(Bundle.main.fullVersion)
        Current locale: \(Locale.preferredLanguages.first ?? "")
        """
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
