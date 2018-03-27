// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya
import Result

class DAppsViewModel {

    private let apiProvider = TrustProviderFactory.makeAPIProvider()

    init() {

    }

    func fetch(
        completion: @escaping (Result<DAppsBootstrap, AnyError>) -> Void
    ) {
        apiProvider.request(.dappsBootstrap) { result in
            switch result {
            case .success(let response):
                do {
                    let dapps = try response.map(DAppsBootstrap.self)
                    completion(.success(dapps))
                } catch {
                    completion(.failure(AnyError(error)))
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
