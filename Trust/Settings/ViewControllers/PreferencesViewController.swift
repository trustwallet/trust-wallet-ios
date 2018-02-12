// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

class PreferencesViewController: FormViewController {

    let viewModel = PreferencesViewModel()
    let preferences: PreferencesController

    init(
        preferences: PreferencesController = PreferencesController()
    ) {
        self.preferences = preferences
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

        <<< SwitchRow {
            $0.title = viewModel.showTokensTabTitle
            $0.value = preferences.get(for: .showTokensOnLaunch)
        }.onChange { [unowned self] row in
            self.preferences.set(value: row.value ?? false, for: .showTokensOnLaunch)
        }.cellSetup { cell, _ in
            cell.imageView?.image = R.image.coins()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
