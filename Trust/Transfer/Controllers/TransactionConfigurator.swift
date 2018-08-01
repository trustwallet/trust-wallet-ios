// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import Result
import TrustCore
import TrustKeystore
import JSONRPCKit
import APIKit

public struct PreviewTransaction {
    let value: BigInt
    let account: Account
    let address: EthereumAddress?
    let contract: EthereumAddress?
    let nonce: BigInt
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let transfer: Transfer
}

final class TransactionConfigurator {

    let session: WalletSession
    let account: Account
    let transaction: UnconfirmedTransaction
    let forceFetchNonce: Bool
    let server: RPCServer
    let chainState: ChainState
    var configuration: TransactionConfiguration {
        didSet {
            configurationUpdate.value = configuration
        }
    }
    var requestEstimateGas: Bool

    let nonceProvider: NonceProvider

    var configurationUpdate: Subscribable<TransactionConfiguration> = Subscribable(nil)

    init(
        session: WalletSession,
        account: Account,
        transaction: UnconfirmedTransaction,
        server: RPCServer,
        chainState: ChainState,
        forceFetchNonce: Bool = true
    ) {
        self.session = session
        self.account = account
        self.transaction = transaction
        self.server = server
        self.chainState = chainState
        self.forceFetchNonce = forceFetchNonce
        self.requestEstimateGas = transaction.gasLimit == .none

        let data: Data = TransactionConfigurator.data(for: transaction, from: account.address)
        let calculatedGasLimit = transaction.gasLimit ?? TransactionConfigurator.gasLimit(for: transaction.transfer.type)
        let calculatedGasPrice = min(max(transaction.gasPrice ?? chainState.gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min), GasPriceConfiguration.max)

        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: server, address: account.address)
        self.nonceProvider = nonceProvider

        self.configuration = TransactionConfiguration(
            gasPrice: calculatedGasPrice,
            gasLimit: calculatedGasLimit,
            data: data,
            nonce: transaction.nonce ?? BigInt(nonceProvider.nextNonce ?? -1)
        )
    }

    private static func data(for transaction: UnconfirmedTransaction, from: Address) -> Data {
        guard let to = transaction.to else { return Data() }
        switch transaction.transfer.type {
        case .ether, .dapp:
            return transaction.data ?? Data()
        case .token:
            return ERC20Encoder.encodeTransfer(to: to, tokens: transaction.value.magnitude)
        }
    }

    private static func gasLimit(for type: TransferType) -> BigInt {
        switch type {
        case .ether:
            return GasLimitConfiguration.default
        case .token:
            return GasLimitConfiguration.tokenTransfer
        case .dapp:
            return GasLimitConfiguration.dappTransfer
        }
    }

    private static func gasPrice(for type: Transfer) -> BigInt {
        return GasPriceConfiguration.default
    }

    func load(completion: @escaping (Result<Void, AnyError>) -> Void) {
        if requestEstimateGas {
            estimateGasLimit { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let gasLimit):
                    self.refreshGasLimit(gasLimit)
                case .failure: break
                }
            }
        }
        loadNonce(completion: completion)
    }

    func estimateGasLimit(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        let request = EstimateGasRequest(
            transaction: signTransaction
        )
        Session.send(EtherServiceRequest(for: server, batch: BatchFactory().create(request))) { result in
            switch result {
            case .success(let gasLimit):
                let gasLimit: BigInt = {
                    let limit = BigInt(gasLimit.drop0x, radix: 16) ?? BigInt()
                    if limit == BigInt(21000) {
                        return limit
                    }
                    return limit + (limit * 20 / 100)
                }()
                completion(.success(gasLimit))
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }

    // combine into one function

    func refreshGasLimit(_ gasLimit: BigInt) {
        configuration = TransactionConfiguration(
            gasPrice: configuration.gasPrice,
            gasLimit: gasLimit,
            data: configuration.data,
            nonce: configuration.nonce
        )
    }

    func refreshNonce(_ nonce: BigInt) {
        configuration = TransactionConfiguration(
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            data: configuration.data,
            nonce: nonce
        )
    }

    func loadNonce(completion: @escaping (Result<Void, AnyError>) -> Void) {
        nonceProvider.getNextNonce(force: forceFetchNonce) { [weak self] result in
            switch result {
            case .success(let nonce):
                self?.refreshNonce(nonce)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func valueToSend() -> BigInt {
        var value = transaction.value
        switch transaction.transfer.type.token.type {
        case .coin:
            let balance = Balance(value: transaction.transfer.type.token.valueBigInt)
            if !balance.value.isZero && balance.value == transaction.value {
                value = transaction.value - configuration.gasLimit * configuration.gasPrice
                //We work only with positive numbers.
                if value.sign == .minus {
                    value = BigInt(value.magnitude)
                }
            }
            return value
        case .ERC20:
            return value
        }
    }

    func previewTransaction() -> PreviewTransaction {
        return PreviewTransaction(
            value: valueToSend(),
            account: account,
            address: transaction.to,
            contract: .none,
            nonce: configuration.nonce,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            transfer: transaction.transfer
        )
    }

    var signTransaction: SignTransaction {
        let value: BigInt = {
            switch transaction.transfer.type {
            case .ether, .dapp: return valueToSend()
            case .token: return 0
            }
        }()
        let address: EthereumAddress? = {
            switch transaction.transfer.type {
            case .ether, .dapp: return transaction.to
            case .token(let token): return token.contractAddress
            }
        }()
        let localizedObject: LocalizedOperationObject? = {
            switch transaction.transfer.type {
            case .ether, .dapp: return .none
            case .token(let token):
                return LocalizedOperationObject(
                    from: account.address.description,
                    to: transaction.to?.description ?? "",
                    contract: token.contract,
                    type: OperationType.tokenTransfer.rawValue,
                    value: BigInt(transaction.value.magnitude).description,
                    symbol: token.symbol,
                    name: token.name,
                    decimals: token.decimals
                )
            }
        }()

        let signTransaction = SignTransaction(
            value: value,
            account: account,
            to: address,
            nonce: configuration.nonce,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            chainID: server.chainID,
            localizedObject: localizedObject
        )

        return signTransaction
    }

    func update(configuration: TransactionConfiguration) {
        self.configuration = configuration
    }

    func balanceValidStatus() -> BalanceStatus {
        var etherSufficient = true
        var gasSufficient = true
        var tokenSufficient = true

        // fetching price of the coin, not the erc20 token.
        let coin = session.tokensStorage.getToken(for: self.transaction.transfer.type.token.coin.server.priceID)
        let currentBalance = coin?.valueBalance

        guard let balance = currentBalance else {
            return .ether(etherSufficient: etherSufficient, gasSufficient: gasSufficient)
        }
        let transaction = previewTransaction()
        let totalGasValue = transaction.gasPrice * transaction.gasLimit

        //We check if it is ETH or token operation.
        switch transaction.transfer.type {
        case .ether, .dapp:
            if transaction.value > balance.value {
                etherSufficient = false
                gasSufficient = false
            } else {
                if totalGasValue + transaction.value > balance.value {
                    gasSufficient = false
                }
            }
            return .ether(etherSufficient: etherSufficient, gasSufficient: gasSufficient)
        case .token(let token):
            if totalGasValue > balance.value {
                etherSufficient = false
                gasSufficient = false
            }
            if transaction.value > token.valueBigInt {
                tokenSufficient = false
            }
            return .token(tokenSufficient: tokenSufficient, gasSufficient: gasSufficient)
        }
    }
}
