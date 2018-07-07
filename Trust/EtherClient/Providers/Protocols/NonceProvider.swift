// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import Result

protocol NonceProvider {
    var remoteNonce: BigInt? { get }
    var latestNonce: BigInt? { get }
    var nextNonce: BigInt? { get }
    var nonceAvailable: Bool { get }
    func getNextNonce(force: Bool, completion: @escaping (Result<BigInt, AnyError>) -> Void)
}
