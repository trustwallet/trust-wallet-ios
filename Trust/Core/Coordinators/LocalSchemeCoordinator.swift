// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import TrustWalletSDK
import BigInt
import Result

protocol LocalSchemeCoordinatorDelegate: class {
    func didCancel(in coordinator: LocalSchemeCoordinator)
}

final class LocalSchemeCoordinator: Coordinator {

    let navigationController: NavigationController
    let keystore: Keystore
    let session: WalletSession
    var coordinators: [Coordinator] = []
    weak var delegate: LocalSchemeCoordinatorDelegate?
    lazy var trustWalletSDK: TrustWalletSDK = {
        return TrustWalletSDK(delegate: self)
    }()

    lazy var server: RPCServer = {
        return RPCServer(chainID: 1)!
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
    private func signMessage(for account: Account, signMessage: SignMesageType, completion: @escaping (Result<Data, WalletSDKError>) -> Void) {
        let coordinator = SignMessageCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            account: account
        )
        coordinator.didComplete = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                if let dappError = error.error as? DAppError, dappError == .cancelled {
                    completion(.failure(WalletSDKError.cancelled))
                } else {
                    completion(.failure(WalletSDKError.unknown))
                }
            }
            coordinator.didComplete = nil
            self.removeCoordinator(coordinator)
        }
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(with: signMessage)
    }

    private func signTransaction(account: Account, transaction: UnconfirmedTransaction, type: ConfirmType, completion: @escaping (Result<Data, WalletSDKError>) -> Void) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction,
            server: server,
            chainState: ChainState(server: server),
            forceFetchNonce: true
        )
        let coordinator = ConfirmCoordinator(
            session: session,
            configurator: configurator,
            keystore: keystore,
            account: account,
            type: type,
            server: server
        )
        addCoordinator(coordinator)
        coordinator.didCompleted = { [unowned self] result in
            switch result {
            case .success(let type):
                switch type {
                case .signedTransaction(let transaction):
                    completion(.success(transaction.data))
                case .sentTransaction(let transaction):
                    completion(.success(transaction.data))
                }
            case .failure(let error):
                if let dappError = error.error as? DAppError, dappError == .cancelled {
                    completion(.failure(WalletSDKError.cancelled))
                } else {
                    completion(.failure(WalletSDKError.unknown))
                }
            }
            coordinator.didCompleted = nil
            self.removeCoordinator(coordinator)
            self.navigationController.dismiss(animated: true, completion: nil)
        }
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    private func account(for session: WalletSession) -> Account? {
        return session.account.currentAccount
    }
}

extension LocalSchemeCoordinator: SignMessageCoordinatorDelegate {
    func didCancel(in coordinator: SignMessageCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        coordinator.didComplete = nil
        delegate?.didCancel(in: self)
    }
}

extension LocalSchemeCoordinator: WalletDelegate {
    func signMessage(_ message: Data, address: Address?, completion: @escaping (Result<Data, WalletSDKError>) -> Void) {
        guard let account = account(for: session) else {
            return completion(.failure(WalletSDKError.watchOnly))
        }
        signMessage(for: account, signMessage: .message(message), completion: completion)
    }

    func signPersonalMessage(_ message: Data, address: Address?, completion: @escaping (Result<Data, WalletSDKError>) -> Void) {
        guard let account = account(for: session) else {
            return completion(.failure(WalletSDKError.watchOnly))
        }
        signMessage(for: account, signMessage: .personalMessage(message), completion: completion)
    }

    func signTransaction(_ transaction: TrustCore.Transaction, completion: @escaping (Result<Data, WalletSDKError>) -> Void) {
        let transaction = UnconfirmedTransaction(
            transfer: Transfer(server: server, type: .ether(destination: .none)),
            value: transaction.amount,
            to: transaction.to,
            data: transaction.payload,
            gasLimit: BigInt(transaction.gasLimit),
            gasPrice: transaction.gasPrice,
            nonce: BigInt(transaction.nonce)
        )

        guard let account = account(for: session) else {
            return completion(.failure(WalletSDKError.watchOnly))
        }
        signTransaction(account: account, transaction: transaction, type: .sign, completion: completion)
    }
}
