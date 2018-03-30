// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

protocol NetworksViewControllerDelegate: class {
    func didClickAddNetwork()
}

class NetworksViewController: FormViewController {

    weak var delegate: NetworksViewControllerDelegate?
    var headerTitle: String?

    private let config = Config()
    private let networksStore: RPCStore

    lazy var viewModel: NetworksViewModel = {
        return NetworksViewModel(networksStore: networksStore)
    }()

    init(
        networksStore: RPCStore
    ) {
        self.networksStore = networksStore
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNetwork))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func addNetwork() {
        delegate?.didClickAddNetwork()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ SelectableSection<ListCheckRow<String>>("", selectionType: .singleSelection(enableDeselection: true))
        for server in viewModel.servers where server.networkType == .main {
            form.last! <<< ListCheckRow<String>(server.displayName) { listRow in
                listRow.title = server.displayName
                listRow.selectableValue = server.displayName
                listRow.value = nil
            }
        }

        form +++ SelectableSection<ListCheckRow<String>>("TEST", selectionType: .singleSelection(enableDeselection: true))
        for server in viewModel.servers where server.networkType == .test {
            form.last! <<< ListCheckRow<String>(server.displayName) { listRow in
                listRow.title = server.displayName
                listRow.selectableValue = server.displayName
                listRow.value = nil
            }
        }

        if !self.viewModel.customServers.isEmpty {
            form +++ SelectableSection<ListCheckRow<String>>("CUSTOM", selectionType: .singleSelection(enableDeselection: true))
            for server in viewModel.customServers where server.networkType == .custom {
                form.last! <<< ListCheckRow<String>(server.name) { listRow in
                    listRow.title = server.name
                    listRow.selectableValue = server.name
                    listRow.value = nil
                }
            }
        }

            /*+++ PushRow<RPCServer> { [weak self] in
                guard let strongSelf = self else { return }
                $0.title = strongSelf.viewModel.networkTitle
                $0.options = strongSelf.viewModel.servers
                $0.value = RPCServer(chainID: strongSelf.config.chainID)
                $0.selectorTitle = strongSelf.viewModel.networkTitle
                $0.displayValueFor = { value in
                    return value?.displayName
                }
            }.onChange { [weak self] row in
                let server = row.value ?? RPCServer.main
            }.onPresent { _, selectorController in
                    
            }.cellSetup { cell, _ in
                    
            }*/
    }
}
