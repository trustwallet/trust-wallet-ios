// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

class NetworksViewController: FormViewController {

    lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addNetwork))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = false
        let nameList = ["1"]


        let section =  MultivaluedSection(multivaluedOptions: .None, footer: "")
        for _ in 1..<4 {
            section <<< PickerInlineRow<String> {
                $0.title = "Tap to select"
                $0.value = "client"
                $0.options = nameList
            }
        }

        form +++ section
    }

    @objc func addNetwork(sender: UIBarButtonItem) {

    }
}
