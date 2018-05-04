// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import JSONRPCKit
import PromiseKit
import APIKit

enum ENSError: LocalizedError {
    case decodeError
}

class ENSClient {

    static let ensContrct = Address(string: "0x314159265dd8dbb310642f98f50c066173c1259b")!
    static let reverseResolverContract = Address(string: "0x5fbb459c49bb06083c33109fa4f14810ec2cf358")!
    static let reverseSuffix = "addr.reverse"

    static func resolve(name: String) -> Promise<Address> {
        let node = namehash(name)
        let encoded = ENSEncoder.encodeOwner(node: node)
        let request = EtherServiceRequest(
            batch: BatchFactory().create(CallRequest(to: ENSClient.ensContrct.description, data: encoded.hexEncoded))
        )
        return Promise { seal in
            Session.send(request) { result in
                switch result {
                case .success(let response):
                    let data = Data(hex: response)
                    guard data.count == 32 else {
                        return seal.reject(ENSError.decodeError)
                    }
                    let sub = Data(bytes: data.bytes[12...])
                    seal.fulfill(Address(data: sub))
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func lookup(address: Address) -> Promise<String> {
        let addr = [address.data.hex, ENSClient.reverseSuffix].joined(separator: ".")
        let node = namehash(addr)
        let encoded = ReverseResolverEncoder.encodeName(node)
        let request = EtherServiceRequest(
            batch: BatchFactory().create(CallRequest(to: ENSClient.reverseResolverContract.description, data: encoded.hexEncoded))
        )
        return Promise { seal in
            Session.send(request) { result in
                switch result {
                case .success(let response):
                    let data = Data(hex: response)
                    let decoder = ABIDecoder(data: data)
                    let decoded = try? decoder.decodeTuple(types: [.string])
                    guard let string = decoded?.first?.nativeValue as? String else {
                        return seal.reject(ENSError.decodeError)
                    }
                    seal.fulfill(string)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
