// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import Branch
import Crashlytics

final class DeveloperViewController: FormViewController {

    let preferencesController = PreferencesController()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = R.string.localizable.developer()

        form +++ Section()
        <<< SwitchRow {
            $0.title = R.string.localizable.enableTestNetworks()
            $0.value = self.preferencesController.get(for: .testNetworks)
        }.onChange { [weak self] row in
            guard let enabled = row.value else { return }
            self?.preferencesController.set(value: enabled, for: .testNetworks)
        }
    }
}
