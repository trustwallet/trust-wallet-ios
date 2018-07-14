// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

protocol TokensCoordinatorDelegate: class {
    func didPress(for type: PaymentFlow, in coordinator: TokensCoordinator)
    func didPress(url: URL, in coordinator: TokensCoordinator)
    func didPressDiscover(in coordinator: TokensCoordinator)
    func didPressChangeWallet(in coordinator: TokensCoordinator)
}

final class TokensCoordinator: Coordinator {

    let navigationController: NavigationController
    let session: WalletSession
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    let store: TokensDataStore
    let network: NetworkProtocol
    let transactionsStore: TransactionsStorage

    lazy var tokensViewController: TokensViewController = {
        let tokensViewModel = TokensViewModel(wallet: session.account, store: store, tokensNetwork: network, transactionStore: transactionsStore)
        let controller = TokensViewController(viewModel: tokensViewModel)
        controller.footerView.requestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
        controller.footerView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        controller.delegate = self
        controller.titleView.delegate = self
        controller.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: R.image.collectibles(), style: .done, target: self, action: #selector(collectibles)),
        ]
        controller.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(edit)),
        ]
        return controller
    }()
    lazy var nonFungibleTokensViewController: NonFungibleTokensViewController = {
        let nonFungibleTokenViewModel = NonFungibleTokenViewModel(address: session.account.address, storage: store, tokensNetwork: network)
        let controller = NonFungibleTokensViewController(viewModel: nonFungibleTokenViewModel)
        controller.delegate = self
        return controller
    }()
    weak var delegate: TokensCoordinatorDelegate?

    lazy var rootViewController: TokensViewController = {
        return self.tokensViewController
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        tokensStorage: TokensDataStore,
        network: NetworkProtocol,
        transactionsStore: TransactionsStorage
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
        self.store = tokensStorage
        self.network = network
        self.transactionsStore = transactionsStore
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        navigationController.viewControllers = [rootViewController]
    }

    func newTokenViewController(token: ERC20Token?) -> NewTokenViewController {
        let viewModel = NewTokenViewModel(token: token, tokensNetwork: network)
        let controller = NewTokenViewController(token: token, viewModel: viewModel)
        controller.delegate = self
        return controller
    }

    func editTokenViewController(token: TokenObject) -> NewTokenViewController {
        let token: ERC20Token? = {
            guard let address = EthereumAddress(string: token.contract) else {
                return .none
            }
            return ERC20Token(contract: address, name: token.name, symbol: token.symbol, decimals: token.decimals)
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
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        navigationController.pushViewController(controller, animated: true)
    }

    @objc func request() {
        delegate?.didPress(for: .request(token: TokensDataStore.etherToken(for: session.config)), in: self)
    }

    @objc func send() {
        delegate?.didPress(for: .send(type: .ether(destination: .none)), in: self)
    }

    private func openURL(_ url: URL) {
        delegate?.didPress(url: url, in: self)
    }

    func addTokenContract(for contract: EthereumAddress) {
        let _ = network.search(token: contract.description).done { [weak self] token in
            self?.store.add(tokens: [token])
        }
    }

    @objc private func collectibles() {
        navigationController.pushViewController(nonFungibleTokensViewController, animated: true)
    }

    private func didSelectToken(_ token: NonFungibleTokenObject, with backgroundColor: UIColor) {
        let controller = NFTokenViewController(token: token)
        controller.delegate = self
        controller.imageView.backgroundColor = backgroundColor
        navigationController.pushViewController(controller, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didSelect(token: TokenObject, in viewController: UIViewController) {
        let controller = TokenViewController(
            viewModel: TokenViewModel(token: token, store: store, transactionsStore: transactionsStore, tokensNetwork: network, session: session)
        )
        controller.delegate = self
        controller.navigationItem.backBarButtonItem = .back
        navigationController.pushViewController(controller, animated: true)
    }

    func didDelete(token: TokenObject, in viewController: UIViewController) {
        store.delete(tokens: [token])
    }

    func didDisable(token: TokenObject, in viewController: UIViewController) {
        store.update(tokens: [token], action: .disable(true))
    }

    func didEdit(token: TokenObject, in viewController: UIViewController) {
        editToken(token)
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

    func didPress(token: NonFungibleTokenObject, with bacground: UIColor) {
        didSelectToken(token, with: bacground)
    }
}

extension TokensCoordinator: TokenViewControllerDelegate {
    func didPressSend(for token: TokenObject, in controller: UIViewController) {
        if TokensDataStore.etherToken(for: session.config) == token {
            delegate?.didPress(for: .send(type: .ether(destination: .none)), in: self)
        } else {
            delegate?.didPress(for: .send(type: .token(token)), in: self)
        }
    }

    func didPressRequest(for token: TokenObject, in controller: UIViewController) {
        delegate?.didPress(for: .request(token: token), in: self)
    }

    func didPress(transaction: Transaction, in controller: UIViewController) {
        let controller = TransactionViewController(
            session: session,
            transaction: transaction
        )
        controller.delegate = self
        NavigationController.openFormSheet(
            for: controller,
            in: navigationController,
            barItem: UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        )
    }

    func didPressInfo(for token: TokenObject, in controller: UIViewController) {
        tokenInfo(token)
    }
}

extension TokensCoordinator: NFTokenViewControllerDelegate {
    func didPressLink(url: URL, in viewController: NFTokenViewController) {
        openURL(url)
    }

    func didPressToken(token: NonFungibleTokenObject, in viewController: NFTokenViewController) {
        delegate?.didPress(for: .send(type: .nft(token)), in: self)
    }
}

extension TokensCoordinator: TransactionViewControllerDelegate {
    func didPressURL(_ url: URL) {
        openURL(url)
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension TokensCoordinator: WalletTitleViewDelegate {
    func didTap(in view: WalletTitleView) {
        delegate?.didPressChangeWallet(in: self)
    }
}
