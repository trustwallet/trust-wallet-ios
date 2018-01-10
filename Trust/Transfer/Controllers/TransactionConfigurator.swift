// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import Result
import TrustKeystore

public struct PreviewTransaction {
    let value: BigInt
    let account: Account
    let address: Address
    let contract: Address?
    let nonce: Int
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let chainID: Int
    let transferType: TransferType
}

class TransactionConfigurator {

    let session: WalletSession
    let account: Account
    let transaction: UnconfirmedTransaction
    private let gasPrice: BigInt?
    var configuration: TransactionConfiguration

    init(
        session: WalletSession,
        account: Account,
        transaction: UnconfirmedTransaction,
        gasPrice: BigInt?
    ) {
        self.session = session
        self.account = account
        self.transaction = transaction
        self.gasPrice = gasPrice

        self.configuration = TransactionConfiguration(
            gasPrice: min(max(gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min), GasPriceConfiguration.max),
            gasLimit: GasLimitConfiguration.default,
            data: Data()
        )
    }

    func load(completion: @escaping (Result<Void, AnyError>) -> Void) {
        let calculatedGasPrice = self.gasPrice ?? configuration.gasPrice
        switch transaction.transferType {
        case .ether:
            self.configuration = TransactionConfiguration(
                gasPrice: calculatedGasPrice,
                gasLimit: 90000,
                data: transaction.data ?? self.configuration.data
            )
            completion(.success(()))
        case .token:
            session.web3.request(request: ContractERC20Transfer(amount: transaction.value, address: transaction.address.address)) { result in
                switch result {
                case .success(let res):
                    let data = Data(hex: res.drop0x)
                    self.configuration = TransactionConfiguration(
                        gasPrice: calculatedGasPrice,
                        gasLimit: 144000,
                        data: data
                    )
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .exchange:
            // TODO
            self.configuration = TransactionConfiguration(
                gasPrice: calculatedGasPrice,
                gasLimit: 300_000,
                data: Data()
            )
            completion(.success(()))
        }
    }

    func previewTransaction() -> PreviewTransaction {
        return PreviewTransaction(
            value: transaction.value,
            account: transaction.account,
            address: transaction.address,
            contract: .none,
            nonce: 0,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            chainID: transaction.chainID,
            transferType: transaction.transferType
        )
    }

    func signTransaction() -> SignTransaction {
        let value: BigInt = {
            switch transaction.transferType {
            case .ether: return transaction.value
            case .token, .exchange: return 0
            }
        }()
        let address: Address = {
            switch transaction.transferType {
            case .ether, .exchange: return transaction.address
            case .token(let token): return token.address
            }
        }()
        let signTransaction = SignTransaction(
            value: value,
            account: account,
            address: address,
            nonce: 0,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            chainID: transaction.chainID
        )

        return signTransaction
    }

    func update(configuration: TransactionConfiguration) {
        self.configuration = configuration
    }
}
