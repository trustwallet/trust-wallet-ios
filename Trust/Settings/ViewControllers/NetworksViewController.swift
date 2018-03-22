// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

protocol NetworksViewControllerDelegate: class {
    //TODO
}

class NetworksViewController: FormViewController {
    weak var delegate: NetworksViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = false
        let nameList = ["Some status info?", "More status data", "Even more data"]

        let section =  MultivaluedSection(multivaluedOptions: .None, footer: "eyee")
        for _ in 1..<4 {
            section <<< PickerInlineRow<String> {
                $0.title = "Tap to select"
                $0.value = "client"
                $0.options = nameList
            }
        }

        form +++ section
    }
}
