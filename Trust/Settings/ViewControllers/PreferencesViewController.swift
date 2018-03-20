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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
