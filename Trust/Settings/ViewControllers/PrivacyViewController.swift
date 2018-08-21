// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import Branch

final class PrivacyViewController: FormViewController {

    private let viewModel = AnaliticsViewModel()

    private var amountRow: SwitchRow? {
        return form.rowBy(tag: viewModel.answer.rawValue) as? SwitchRow
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section(footer: viewModel.answer.description)

        <<< SwitchRow(viewModel.answer.rawValue) {
            $0.title = viewModel.answer.title
            $0.value = viewModel.answer.isEnabled
        }.onChange { [weak self] row in
            guard let enabled = row.value else { return }
            self?.viewModel.answer.update(with: enabled)
        }
        form +++ Section(footer: viewModel.branch.description)
        <<< SwitchRow {
            $0.title = viewModel.branch.title
            $0.value = viewModel.branch.isEnabled
        }.onChange { [weak self] row in
             guard let enabled = row.value else { return }
             self?.viewModel.branch.update(with: enabled)
             Branch.setTrackingDisabled(!enabled)
        }
    }
}
