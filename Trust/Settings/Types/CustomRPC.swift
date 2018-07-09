// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class CustomRPC: Object {
    @objc dynamic var chainID: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var endpoint: String = ""
    @objc dynamic var wssEndpoint: String = ""
    @objc dynamic var id: String = UUID().uuidString

    convenience init(
        chainID: Int = 0,
        name: String = "",
        symbol: String = "",
        endpoint: String = "",
        wssEndpoint: String = ""
    ) {
        self.init()
        self.chainID = chainID
        self.name = name
        self.symbol = symbol
        self.endpoint = endpoint
        self.wssEndpoint = wssEndpoint
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
