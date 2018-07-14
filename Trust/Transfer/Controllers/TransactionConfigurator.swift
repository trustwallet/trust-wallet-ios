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
    let transferType: TransferType
}

final class TransactionConfigurator {

    let session: WalletSession
    let account: Account
    let transaction: UnconfirmedTransaction
    let forceFetchNonce: Bool
    var configuration: TransactionConfiguration {
        didSet {
            configurationUpdate.value = configuration
        }
    }
    var requestEstimateGas: Bool

    var configurationUpdate: Subscribable<TransactionConfiguration> = Subscribable(nil)

    init(
        session: WalletSession,
        account: Account,
        transaction: UnconfirmedTransaction,
        forceFetchNonce: Bool = false
    ) {
        self.session = session
        self.account = account
        self.transaction = transaction
        self.forceFetchNonce = forceFetchNonce
        self.requestEstimateGas = transaction.gasLimit == .none

        let nonce = transaction.nonce ?? BigInt(session.nonceProvider.nextNonce ?? -1)
        let data: Data = TransactionConfigurator.data(for: transaction, from: account.address)
        let calculatedGasLimit = transaction.gasLimit ?? TransactionConfigurator.gasLimit(for: transaction.transferType)
        let calculatedGasPrice = min(max(transaction.gasPrice ?? session.chainState.gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min), GasPriceConfiguration.max)

        self.configuration = TransactionConfiguration(
            gasPrice: calculatedGasPrice,
            gasLimit: calculatedGasLimit,
            data: data,
            nonce: nonce
        )
    }

    private static func data(for transaction: UnconfirmedTransaction, from: Address) -> Data {
        guard let from = from as? EthereumAddress else { return Data() }
        guard let to = transaction.to else { return Data() }
        switch transaction.transferType {
        case .ether, .dapp:
            return transaction.data ?? Data()
        case .token:
            return ERC20Encoder.encodeTransfer(to: to, tokens: transaction.value.magnitude)
        case .nft(let token):
            let tokenID = BigUInt(token.id) ?? 0
            return ERC721Encoder.encodeTransferFrom(from: from, to: to, tokenId: tokenID)
        }
    }

    private static func gasLimit(for type: TransferType) -> BigInt {
        switch type {
        case .ether:
            return GasLimitConfiguration.default
        case .token:
            return GasLimitConfiguration.tokenTransfer
        case .dapp, .nft:
            return GasLimitConfiguration.dappTransfer
        }
    }

    private static func gasPrice(for type: TransferType) -> BigInt {
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
        Session.send(EtherServiceRequest(batch: BatchFactory().create(request))) { result in
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
        session.nonceProvider.getNextNonce(force: forceFetchNonce) { [weak self] result in
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
        if let balance = session.balance?.value,
            balance == transaction.value {
            value = transaction.value - configuration.gasLimit * configuration.gasPrice
            //We work only with positive numbers.
            if value.sign == .minus {
                value = BigInt(value.magnitude)
            }
        }
        return value
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
            transferType: transaction.transferType
        )
    }

    var signTransaction: SignTransaction {
        let value: BigInt = {
            switch transaction.transferType {
            case .ether, .dapp: return valueToSend()
            case .token, .nft: return 0
            }
        }()
        let address: EthereumAddress? = {
            switch transaction.transferType {
            case .ether, .dapp: return transaction.to
            case .token(let token): return token.contractAddress
            case .nft(let token): return token.contractAddress
            }
        }()
        let localizedObject: LocalizedOperationObject? = {
            switch transaction.transferType {
            case .ether, .dapp, .nft: return .none
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
            chainID: session.config.chainID,
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

        guard let balance = session.balance else {
            return .ether(etherSufficient: etherSufficient, gasSufficient: gasSufficient)
        }
        let transaction = previewTransaction()
        let totalGasValue = transaction.gasPrice * transaction.gasLimit

        //We check if it is ETH or token operation.
        switch transaction.transferType {
        case .ether, .dapp, .nft:
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
