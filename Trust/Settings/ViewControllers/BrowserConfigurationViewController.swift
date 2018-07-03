// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka
import WebKit
import Realm

protocol BrowserConfigurationViewControllerDelegate: class {
    func didPressDeleteCache(in controller: BrowserConfigurationViewController)
}

class BrowserConfigurationViewController: FormViewController {

    let viewModel = BrowserConfigurationViewModel()
    let preferences: PreferencesController
    weak var delegate: BrowserConfigurationViewControllerDelegate?

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
            $0.displayValueFor = { $0?.title }
        }.onChange { [weak self] row in
            guard let value = row.value else { return }
            self?.preferences.set(value: value.rawValue, for: .browserSearchEngine)
        }.onPresent { _, selectorController in
            selectorController.sectionKeyForValue = { _ in
                return ""
            }
        }

        +++ Section()

        <<< AppFormAppearance.button { [weak self] in
            guard let `self` = self else { return }
            $0.title = self.viewModel.clearBrowserCacheTitle
        }.onCellSelection { [weak self] _, _ in
            guard let `self` = self else { return }
            self.confirm(
                title: self.viewModel.clearBrowserCacheConfirmTitle,
                message: self.viewModel.clearBrowserCacheConfirmMessage,
                okTitle: R.string.localizable.delete(),
                okStyle: .destructive,
                completion: { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success:
                        self.delegate?.didPressDeleteCache(in: self)
                    case .failure: break
                    }
            })
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
