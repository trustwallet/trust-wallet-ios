// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

protocol NetworksViewControllerDelegate: class {
    //TODO
}

class NetworksViewController: FormViewController {
    
    weak var delegate: NetworksViewControllerDelegate?
    var headerTitle: String?
    /*var viewModel: NetworksViewModel {
        
    }*/
    private let config = Config()

    override func viewDidLoad() {
        super.viewDidLoad()

        form = Section()

            +++ PushRow<RPCServer> { [weak self] in
                guard let strongSelf = self else { return }
                $0.title = "strongSelf.viewModel.networkTitle"
                //$0.options = strongSelf
                
            }.onChange { [weak self] row in
                    
            }.onPresent { _, selectorController in
                    
            }.cellSetup { cell, _ in
                    
            }
    }
}
