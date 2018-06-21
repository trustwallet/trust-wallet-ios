// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import Branch
import Crashlytics

class AnaliticsViewController: FormViewController {

    private let viewModel = AnaliticsViewModel()

    private var amountRow: SwitchRow? {
        return form.rowBy(tag: viewModel.answer.name) as? SwitchRow
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

            <<< SwitchRow(viewModel.answer.name) {
                $0.title = viewModel.answer.name
                $0.value = viewModel.answer.isEnabled
            }.onChange { [weak self] row in
                guard let enabled = row.value, enabled != self?.viewModel.answer.isEnabled else { return }
                self?.showAnswerAlert()
            }

            <<< SwitchRow {
                $0.title = viewModel.branch.name
                $0.value = viewModel.branch.isEnabled
            }.onChange { [weak self] row in
                 guard let enabled = row.value else { return }
                 self?.viewModel.branch.update(with: enabled)
                 Branch.setTrackingDisabled(!enabled)
            }

            <<< SwitchRow {
                $0.title = viewModel.crashlytics.name
                $0.value = viewModel.crashlytics.isEnabled
            }.onChange { [weak self] row in
                 self?.viewModel.crashlytics.update(with: row.value ?? false)
            }
        }

    private func showAnswerAlert() {
        let state = viewModel.answer.isEnabled
        let title = state ? viewModel.alertTitleDisable :  viewModel.alertTitleEnable
        let alert = UIAlertController(title: "Trust", message: title, preferredStyle: .alert)
        let restart = UIAlertAction(title: viewModel.alertRestart, style: .destructive, handler: { [weak self] (_ action: UIAlertAction) -> Void in
            self?.viewModel.answer.update(with: !state)
            Crashlytics.sharedInstance().crash()
        })
        let cancel = UIAlertAction(title: viewModel.alertCancel, style: .default, handler: { [weak self] (_ action: UIAlertAction) -> Void in
            self?.amountRow?.value = state
            self?.amountRow?.reload()
        })
        alert.addAction(restart)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
