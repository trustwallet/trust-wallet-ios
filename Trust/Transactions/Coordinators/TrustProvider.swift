// Copyright SIX DAY LLC. All rights reserved.

import Alamofire
import Foundation
import Moya

struct TrustProviderFactory {
    static let policies: [String: ServerTrustPolicy] = [
        "trustwalletapp.com": .pinPublicKeys(
            publicKeys: ServerTrustPolicy.publicKeys(in: Bundle.main),
            validateCertificateChain: true,
            validateHost: true
        ),
    ]

    static func makeProvider() -> MoyaProvider<TrustService> {
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        return MoyaProvider<TrustService>(manager: manager)
    }
}
