// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import TrustWalletSDK
import BigInt

protocol LocalSchemeCoordinatorDelegate: class {
    func didCancel(in coordinator: LocalSchemeCoordinator)
}

class LocalSchemeCoordinator: Coordinator {

    let navigationController: NavigationController
    let keystore: Keystore
    let session: WalletSession
    var coordinators: [Coordinator] = []
    weak var delegate: LocalSchemeCoordinatorDelegate?
    lazy var trustWalletSDK: TrustWalletSDK = {
        return TrustWalletSDK(delegate: self)
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        keystore: Keystore,
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.session = session
    }

    func start() {

    }

    func signMessage(for account: Account, message: Data, completion: @escaping (Data?) -> Void) {
        let coordinator = SignMessageCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            account: account
        )
        coordinator.didComplete = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                completion(data)
            case .failure:
                completion(nil)
            }
            self.removeCoordinator(coordinator)
        }
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(with: .message(message))
    }

    private func signTransaction(account: Account, transaction: UnconfirmedTransaction, type: ConfirmType, completion: @escaping (TrustCore.Transaction?) -> Void) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction
        )
        let coordinator = ConfirmCoordinator(
            navigationController: NavigationController(),
            session: session,
            configurator: configurator,
            keystore: keystore,
            account: account,
            type: type
        )
        addCoordinator(coordinator)
        coordinator.didCompleted = { [unowned self] result in
            switch result {
            case .success(let type):
                switch type {
                case .signedTransaction(let transaction): break
                    //completion(transaction)
                    // on signing we pass signed hex of the transaction
//                    let callback = DappCallback(id: callbackID, value: .signTransaction(transaction.data))
//                    self.rootViewController.browserViewController.notifyFinish(callbackID: callbackID, value: .success(callback))
//                    self.delegate?.didSentTransaction(transaction: transaction, in: self)
                case .sentTransaction(let transaction): break
                    //completion(transaction)
                    // on send transaction we pass transaction ID only.
//                    let data = Data(hex: transaction.id)
//                    let callback = DappCallback(id: callbackID, value: .sentTransaction(data))
//                    self.rootViewController.browserViewController.notifyFinish(callbackID: callbackID, value: .success(callback))
//                    self.delegate?.didSentTransaction(transaction: transaction, in: self)
                }
                // analytics event for successfully completed transaction
                // can we track by type without separate events for each case above?
                Analytics.track(.completedTransactionFromBrowser)
            case .failure: break
//                self.rootViewController.browserViewController.notifyFinish(
//                    callbackID: callbackID,
//                    value: .failure(DAppError.cancelled)
//                )
                // analytics event for failed transaction
                // Analytics.track(.failedTransactionFromBrowser)
            }
            self.removeCoordinator(coordinator)
            self.navigationController.dismiss(animated: true, completion: nil)
        }
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension LocalSchemeCoordinator: SignMessageCoordinatorDelegate {
    func didCancel(in coordinator: SignMessageCoordinator) {
        //coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}

extension LocalSchemeCoordinator: WalletDelegate {
    func signMessage(_ message: Data, address: Address?, completion: @escaping (Data?) -> Void) {
        switch session.account.type {
        case .privateKey(let account), .hd(let account):
            signMessage(for: account, message: message, completion: completion)
        case .address:
            break
        }
    }

    func signTransaction(_ transaction: TrustCore.Transaction, completion: @escaping (TrustCore.Transaction?) -> Void) {
        let transaction = UnconfirmedTransaction(
            transferType: .ether(destination: .none),
            value: transaction.amount,
            to: transaction.to,
            data: transaction.payload,
            gasLimit: BigInt(transaction.gasLimit),
            gasPrice: transaction.gasPrice,
            nonce: BigInt(transaction.nonce)
        )

        switch session.account.type {
        case .privateKey(let account), .hd(let account):
            signTransaction(account: account, transaction: transaction, type: .sign, completion: completion)
        case .address:
            break
        }
    }
}
