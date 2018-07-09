// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import TrustKeystore

protocol EnterPasswordViewControllerDelegate: class {
    func didEnterPassword(password: String, for account: Account, in viewController: EnterPasswordViewController)
}

final class EnterPasswordViewController: FormViewController {

    struct Values {
        static var password = "password"
        static var confirmPassword = "confirmPassword"
    }
    weak var delegate: EnterPasswordViewControllerDelegate?
    private let viewModel = EnterPasswordViewModel()

    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password) as? TextFloatLabelRow
    }

    var confirmPasswordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.confirmPassword) as? TextFloatLabelRow
    }

    private let account: Account

    init(
        account: Account
    ) {
        self.account = account

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        let ruleMin = RuleMinLength(minLength: 6)

        form
            +++ Section()

            +++ Section(header: "", footer: viewModel.headerSectionText)

            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.add(rule: RuleRequired())
                $0.add(rule: ruleMin)
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { [unowned self] cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.placeholder = self.viewModel.passwordFieldPlaceholder
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.confirmPassword) { [unowned self] in
                $0.add(rule: RuleRequired())
                $0.add(rule: ruleMin)
                $0.add(rule: RuleEqualsToRow(form: self.form, tag: Values.password, msg: self.viewModel.passwordNoMatch))
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { [unowned self] cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.placeholder = self.viewModel.confirmPasswordFieldPlaceholder
            }

            +++ Section()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        passwordRow?.cell.textField.becomeFirstResponder()
    }

    @objc func done() {
        guard
            form.validate().isEmpty,
            let password = passwordRow?.value
        else { return }

        delegate?.didEnterPassword(password: password, for: account, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
