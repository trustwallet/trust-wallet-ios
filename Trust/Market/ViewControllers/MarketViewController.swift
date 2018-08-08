// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

class MarketViewController: UIViewController {

    private lazy var segmentController: UISegmentedControl = {
        let items = [
            "-1",
            "-2",
            ]
        let segmentedControl = UISegmentedControl.defaultSegmentedControl(items: items)

//        segmentedControl.selectedSegmentIndex = DetailsViewType.tokens.rawValue
//        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        return segmentedControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.titleView = segmentController
    }
}
