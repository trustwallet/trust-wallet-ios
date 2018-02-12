// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

class PreferencesViewController: FormViewController {

    let viewModel = PreferencesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

            <<< SwitchRow { [weak self] in
                $0.title = viewModel.showTokensTabTitle
                $0.value = viewModel.showTokensTabOnStart
            }.onChange { [unowned self] row in
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.coins()
            }
    }

    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        if row.section === form[0] {
            print("Single Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRow()?.baseValue ?? "No row selected")")
        }
        else if row.section === form[1] {
            print("Mutiple Selection:\((row.section as! SelectableSection<ImageCheckRow<String>>).selectedRows().map({$0.baseValue}))")
        }
    }
}
