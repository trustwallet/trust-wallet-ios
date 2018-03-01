// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol TokensCoordinatorDelegate: class {
    func didPress(for type: PaymentFlow, in coordinator: TokensCoordinator)
    func didPress(on token: NonFungibleToken, in coordinator: TokensCoordinator)
}

class TokensCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    let storage: TokensDataStore
    let network: TokensNetworkProtocol

    lazy var tokensViewController: TokensViewController = {
        let tokensViewModel = TokensViewModel(realmDataStore: storage, tokensNetwork: network)
        let controller = TokensViewController(viewModel: tokensViewModel)
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        return controller
    }()
    weak var delegate: TokensCoordinatorDelegate?

    lazy var rootViewController: TokensViewController = {
        return self.tokensViewController
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        tokensStorage: TokensDataStore,
        network: TokensNetworkProtocol
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
        self.storage = tokensStorage
        self.network = network
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        navigationController.viewControllers = [rootViewController]
    }

    func newTokenViewController(token: ERC20Token?) -> NewTokenViewController {
        let controller = NewTokenViewController(token: token)
        controller.delegate = self
        return controller
    }

    func editTokenViewController(token: TokenItem) -> NewTokenViewController {
        switch token {
        case .token(let token):
            let token: ERC20Token? = {
                guard let address = Address(string: token.contract) else {
                    return .none
                }
                return ERC20Token(contract: address, name: token.name, symbol: token.symbol, decimals: token.decimals)
            }()
            return newTokenViewController(token: token)
        }
    }

    @objc func addToken() {
        let controller = newTokenViewController(token: .none)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true, completion: nil)
    }

    func editToken(_ token: TokenItem) {
        let controller = editTokenViewController(token: token)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true, completion: nil)
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    @objc func edit() {
        let controller = EditTokensViewController(
            session: session,
            storage: storage
        )
        navigationController.pushViewController(controller, animated: true)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didSelect(token: TokenItem, in viewController: UIViewController) {

        switch token {
        case .token(let token):
            let type: TokenType = {
                return TokensDataStore.etherToken(for: session.config) == token ? .ether : .token
            }()

            switch type {
            case .ether:
                delegate?.didPress(for: .send(type: .ether(destination: .none)), in: self)
            case .token:
                delegate?.didPress(for: .send(type: .token(token)), in: self)
            }
        }
    }

    func didDelete(token: TokenItem, in viewController: UIViewController) {
        switch token {
        case .token(let token):
            storage.delete(tokens: [token])
            tokensViewController.fetch()
        }
    }

    func didEdit(token: TokenItem, in viewController: UIViewController) {
        editToken(token)
    }

    func didPressAddToken(in viewController: UIViewController) {
        addToken()
    }
}

extension TokensCoordinator: NewTokenViewControllerDelegate {
    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController) {
        storage.addCustom(token: token)
        tokensViewController.fetch()
        dismiss()
    }
}
