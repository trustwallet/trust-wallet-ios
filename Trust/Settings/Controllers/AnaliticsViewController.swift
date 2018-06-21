// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka

class AnaliticsViewController: FormViewController {

    private let viewModel = AnaliticsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

            <<< SwitchRow {
                $0.title = viewModel.answer.name
                $0.value = viewModel.answer.isEnabled
            }.onChange { [weak self] row in
                self?.viewModel.answer.update(with: row.value ?? false)
            }

            <<< SwitchRow {
                $0.title = viewModel.branch.name
                $0.value = viewModel.branch.isEnabled
            }.onChange { [weak self] row in
                 self?.viewModel.branch.update(with: row.value ?? false)
            }

            <<< SwitchRow {
                $0.title = viewModel.crashlytics.name
                $0.value = viewModel.crashlytics.isEnabled
            }.onChange { [weak self] row in
                 self?.viewModel.crashlytics.update(with: row.value ?? false)
            }
        }
}
