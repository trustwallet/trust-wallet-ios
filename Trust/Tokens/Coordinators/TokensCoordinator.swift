// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

protocol TokensCoordinatorDelegate: class {
    func didPressSend(for token: TokenObject, in coordinator: TokensCoordinator)
    func didPressRequest(for token: TokenObject, in coordinator: TokensCoordinator)
    func didPress(url: URL, in coordinator: TokensCoordinator)
    func didPressDiscover(in coordinator: TokensCoordinator)
}

final class TokensCoordinator: Coordinator {

    let navigationController: NavigationController
    let session: WalletSession
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    let store: TokensDataStore
    let transactionsStore: TransactionsStorage

    lazy var tokensViewController: TokensViewController = {
        let tokensViewModel = TokensViewModel(session: session, store: store, tokensNetwork: network, transactionStore: transactionsStore)
        let controller = TokensViewController(viewModel: tokensViewModel)
        controller.delegate = self
        return controller
    }()
    lazy var nonFungibleTokensViewController: NonFungibleTokensViewController = {
        let nonFungibleTokenViewModel = NonFungibleTokenViewModel(address: session.account.address, storage: store, tokensNetwork: network)
        let controller = NonFungibleTokensViewController(viewModel: nonFungibleTokenViewModel)
        controller.delegate = self
        return controller
    }()

    lazy var masterViewController: WalletViewController = {
        let masterViewController = WalletViewController(
            tokensViewController: tokensViewController,
            nonFungibleTokensViewController: nonFungibleTokensViewController
        )
        masterViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(edit))
        return masterViewController
    }()

    weak var delegate: TokensCoordinatorDelegate?

    lazy var rootViewController: WalletViewController = {
        return masterViewController
    }()

    lazy var network: NetworkProtocol = {
        return TrustNetwork(
            provider: TrustProviderFactory.makeProvider(),
            wallet: session.account
        )
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        tokensStorage: TokensDataStore,
        transactionsStore: TransactionsStorage
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
        self.store = tokensStorage
        self.transactionsStore = transactionsStore
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        navigationController.viewControllers = [rootViewController]
    }

    func newTokenViewController(token: ERC20Token?) -> NewTokenViewController {
        let viewModel = NewTokenViewModel(token: token, session: session, tokensNetwork: network)
        let controller = NewTokenViewController(viewModel: viewModel)
        controller.delegate = self
        return controller
    }

    func editTokenViewController(token: TokenObject) -> NewTokenViewController {
        let token: ERC20Token? = {
            guard let address = EthereumAddress(string: token.contract) else {
                return .none
            }
            return ERC20Token(contract: address, name: token.name, symbol: token.symbol, decimals: token.decimals, coin: token.coin)
        }()
        return newTokenViewController(token: token)
    }

    @objc func addToken() {
        let controller = newTokenViewController(token: .none)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        let nav = NavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true, completion: nil)
    }

    func editToken(_ token: TokenObject) {
        let controller = editTokenViewController(token: token)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        let nav = NavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true, completion: nil)
    }

    func tokenInfo(_ token: TokenObject) {
        let coordinator = TokenInfoCoordinator(token: token)
        navigationController.pushCoordinator(coordinator: coordinator, animated: true)
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    @objc func edit() {
        let controller = EditTokensViewController(
            session: session,
            storage: store,
            network: network
        )
        controller.delegate = self
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        navigationController.pushViewController(controller, animated: true)
    }

    private func openURL(_ url: URL) {
        delegate?.didPress(url: url, in: self)
    }

    func addTokenContract(for contract: Address) {
        let _ = network.search(query: contract.description).done { [weak self] tokens in
            guard let token = tokens.first else { return }
            self?.store.add(tokens: [token])
        }
    }

    @objc private func collectibles() {
        navigationController.pushViewController(nonFungibleTokensViewController, animated: true)
    }

    @objc private func transactions() {
        //let coordinator = TransactionsCoordinator(session: session, storage: transactionsStore, network: network)
        //navigationController.pushCoordinator(coordinator: coordinator, animated: true)
    }

    private func didSelectToken(_ token: CollectibleTokenObject, with backgroundColor: UIColor) {
        let controller = NFTokenViewController(token: token, server: session.currentRPC)
        controller.delegate = self
        controller.imageView.backgroundColor = backgroundColor
        navigationController.pushViewController(controller, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didRequest(token: TokenObject, in viewController: UIViewController) {
        delegate?.didPressRequest(for: token, in: self)
    }

    func didSelect(token: TokenObject, in viewController: UIViewController) {
        let controller = TokenViewController(
            viewModel: TokenViewModel(token: token, store: store, transactionsStore: transactionsStore, tokensNetwork: network, session: session)
        )
        controller.delegate = self
        controller.navigationItem.backBarButtonItem = .back
        navigationController.pushViewController(controller, animated: true)
    }

    func didPressAddToken(in viewController: UIViewController) {
        addToken()
    }
}

extension TokensCoordinator: NewTokenViewControllerDelegate {
    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController) {
        store.addCustom(token: token)
        tokensViewController.fetch()
        dismiss()
    }
}

extension TokensCoordinator: NonFungibleTokensViewControllerDelegate {
    func didPressDiscover() {
        delegate?.didPressDiscover(in: self)
    }

    func didPress(token: CollectibleTokenObject, with bacground: UIColor) {
        didSelectToken(token, with: bacground)
    }
}

extension TokensCoordinator: TokenViewControllerDelegate {
    func didPress(viewModel: TokenViewModel, transaction: Transaction, in controller: UIViewController) {
        let controller = TransactionViewController(
            session: session,
            transaction: transaction,
            tokenViewModel: viewModel
        )
        controller.delegate = self
        NavigationController.openFormSheet(
            for: controller,
            in: navigationController,
            barItem: UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        )
    }
    func didPressSend(for token: TokenObject, in controller: UIViewController) {
        delegate?.didPressSend(for: token, in: self)
    }

    func didPressRequest(for token: TokenObject, in controller: UIViewController) {
        delegate?.didPressRequest(for: token, in: self)
    }

    func didPressInfo(for token: TokenObject, in controller: UIViewController) {
        tokenInfo(token)
    }
}

extension TokensCoordinator: NFTokenViewControllerDelegate {
    func didPressLink(url: URL, in viewController: NFTokenViewController) {
        openURL(url)
    }
}

extension TokensCoordinator: TransactionViewControllerDelegate {
    func didPressURL(_ url: URL) {
        openURL(url)
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension TokensCoordinator: EditTokensViewControllerDelegate {
    func didDelete(token: TokenObject, in controller: EditTokensViewController) {
        store.delete(tokens: [token])
        controller.fetch()
    }

    func didDisable(token: TokenObject, in controller: EditTokensViewController) {
        store.update(tokens: [token], action: .disable(true))
    }

    func didEdit(token: TokenObject, in controller: EditTokensViewController) {
        editToken(token)
    }
}
