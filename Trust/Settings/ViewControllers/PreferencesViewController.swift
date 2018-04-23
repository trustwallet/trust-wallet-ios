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

        <<< PushRow<SearchEngine> { [weak self] in
            guard let `self` = self else { return }
            $0.title = self.viewModel.searchEngineTitle
            $0.options = self.viewModel.searchEngines
            $0.value = SearchEngine(rawValue: self.preferences.get(for: .browserSearchEngine)) ?? .default
            $0.selectorTitle = self.viewModel.searchEngineTitle
            $0.displayValueFor = { value in
                return value?.title
            }
            }.onChange { [weak self] row in
                guard let value = row.value else { return }
                self?.preferences.set(value: value.rawValue, for: .browserSearchEngine)
            }.onPresent { _, selectorController in
                selectorController.enableDeselection = false
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_server()
            }.onPresent { _, selectorController in
                selectorController.enableDeselection = false
                selectorController.sectionKeyForValue = { option in
                    return ""
                }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
