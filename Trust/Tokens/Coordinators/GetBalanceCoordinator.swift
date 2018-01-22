// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import JSONRPCKit
import APIKit
import Result
import TrustKeystore

class GetBalanceCoordinator {

    private let web3: Web3Swift

    init(
        web3: Web3Swift
    ) {
        self.web3 = web3
    }

    func getBalance(
        for address: Address,
        contract: Address,
        completion: @escaping (Result<BigInt, AnyError>) -> Void
    ) {
        let request = GetERC20BalanceEncode(address: address)
        web3.request(request: request) { result in
            switch result {
            case .success(let res):
                let request2 = EtherServiceRequest(
                    batch: BatchFactory().create(CallRequest(to: contract.description, data: res))
                )
                Session.send(request2) { [weak self] result2 in
                    switch result2 {
                    case .success(let balance):
                        let request = GetERC20BalanceDecode(data: balance)
                        self?.web3.request(request: request) { result in
                            switch result {
                            case .success(let res):
                                completion(.success(BigInt(res) ?? BigInt()))
                            case .failure(let error):
                                NSLog("getPrice3 error \(error)")
                                completion(.failure(AnyError(error)))
                            }
                        }
                    case .failure(let error):
                        NSLog("getPrice2 error \(error)")
                        completion(.failure(AnyError(error)))
                    }
                }
            case .failure(let error):
                NSLog("getPrice error \(error)")
                completion(.failure(AnyError(error)))
            }
        }
    }
    func getEthBalance(
        for address: Address,
        completion: @escaping (Result<Balance, AnyError>) -> Void
    ) {
        let request = EtherServiceRequest(batch: BatchFactory().create(BalanceRequest(address: address.description)))
        Session.send(request) { result in
            switch result {
            case .success(let balance):
                completion(.success(balance))
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
