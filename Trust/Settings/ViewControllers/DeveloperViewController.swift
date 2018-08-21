// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import Branch
import TrustCore
import KeychainSwift

struct Node {
    let name: String
    let options: [RPCServer]
    let main: RPCServer
}

struct DeveloperViewModel {

//    private struct Values {
//        static let defaultConfig = "default-config-node-"
//    }
//
//    private let keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)
//
//    var nodes: [Node] {
//        return [
//            Node(
//                name: "Ethereum",
//                options: [RPCServer.main, RPCServer.ropsten, RPCServer.kovan, RPCServer.rinkeby],
//                main: RPCServer.main
//            ),
//            Node(
//                name: RPCServer.poa.name,
//                options: [RPCServer.poa, RPCServer.sokol],
//                main: RPCServer.poa
//            ),
//        ]
//    }
//
//    func defaultServer(for server: RPCServer) -> RPCServer {
//        let key = Values.defaultConfig + "\(server.chainID)"
//        guard let value = keychain.get(key), let intValue = Int(value) else {
//            return server
//        }
//        return RPCServer(chainID: intValue) ?? server
//    }
//
//    func setDefaultServer(for main: RPCServer, active: RPCServer) {
//        let key = Values.defaultConfig + "\(main.chainID)"
//        keychain.set("\(active.chainID)", forKey: key)
//    }
}

protocol DeveloperViewControllerDelegate: class {
    func didClearTransactions(in controller: DeveloperViewController)
    func didClearTokens(in controller: DeveloperViewController)
}

final class DeveloperViewController: FormViewController {

    private let viewModel = DeveloperViewModel()
    let preferencesController = PreferencesController()

    weak var delegate: DeveloperViewControllerDelegate?

    private struct Values {
        static let ethereumNet = "ethereumNet"
        static let ethereumTestNet = "ethereumTestNet"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = R.string.localizable.developer()

//        let section = Section(header: R.string.localizable.nodeSettings(), footer: "")
//
//        form +++ section

//        for node in viewModel.nodes {
//            section.append(nodeRow(for: node))
//        }

        form +++ Section()

//        <<< SwitchRow {
//            $0.title = R.string.localizable.enableTestNetworks()
//            $0.value = self.preferencesController.get(for: .testNetworks)
//        }.onChange { [weak self] row in
//            guard let enabled = row.value else { return }
//            self?.preferencesController.set(value: enabled, for: .testNetworks)
//        }

        <<< AppFormAppearance.button {
            $0.title = "Clear Transactions"
        }.onCellSelection { [weak self] _, _ in
            guard let `self` = self else { return }
            self.delegate?.didClearTransactions(in: self)
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        }

        <<< AppFormAppearance.button {
            $0.title = "Clear Tokens"
        }.onCellSelection { [weak self] _, _ in
            guard let `self` = self else { return }
            self.delegate?.didClearTokens(in: self)
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        }
    }

//    private func nodeRow(for node: Node) -> PushRow<RPCServer> {
//
//        let main = viewModel.defaultServer(for: node.main)
//
//        return PushRow<RPCServer> { [weak self] in
//            $0.title = node.name
//            $0.selectorTitle = node.name
//            $0.options = node.options
//            $0.value = viewModel.defaultServer(for: main)
//            $0.displayValueFor = { value in
//                return value?.name
//            }
//        }.onPresent { _, selectorController in
//            selectorController.enableDeselection = false
//            selectorController.sectionKeyForValue = { option in
//                switch option {
//                case node.main: return Values.ethereumNet
//                default: return Values.ethereumTestNet
//                }
//            }
//            selectorController.sectionHeaderTitleForKey = { option in
//                switch option {
//                case Values.ethereumNet: return .none
//                case Values.ethereumTestNet: return R.string.localizable.testNetworks()
//                default: return ""
//                }
//            }
//        }.onChange { [weak self]  row in
//            guard let value = row.value, let `self` = self else { return }
//            self.viewModel.setDefaultServer(for: main, active: value)
//            self.delegate?.didSelect(server: value, in: self)
//        }
//    }
}
