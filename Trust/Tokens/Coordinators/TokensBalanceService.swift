// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import JSONRPCKit
import APIKit
import Result
import TrustCore

public class TokensBalanceService {

    func getBalance(
        for address: Address,
        contract: Address,
        completion: @escaping (Result<BigInt, AnyError>) -> Void
    ) {
        let encoded = ERC20Encoder.encodeBalanceOf(address: address)
        let request = EtherServiceRequest(
            batch: BatchFactory().create(CallRequest(to: contract.description, data: encoded.hexEncoded))
        )
        Session.send(request) { result in
            switch result {
            case .success(let balance):
                let biguint = BigUInt(Data(hex: balance))
                completion(.success(BigInt(sign: .plus, magnitude: biguint)))
            case .failure(let error):
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
