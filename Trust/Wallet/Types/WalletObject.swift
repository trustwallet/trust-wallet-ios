// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import Realm
import TrustCore

final class WalletObject: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var completedBackup: Bool = false
    @objc dynamic var mainWallet: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }

    static func from(_ type: WalletType) -> WalletObject {
        let info = WalletObject()
        info.id = type.description
        return info
    }
}

final class WalletAddress: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var addressString: String = ""
    @objc dynamic var coinID: Int = 60

    convenience init(
        coin: Coin,
        address: Address
    ) {
        self.init()
        self.id = "\(coin.rawValue)" + "-" + address.description
        self.addressString = address.description
        self.coinID = coin.rawValue
    }

    var coin: Coin? {
        return Coin(rawValue: coinID)
    }

    var address: EthereumAddress? {
        return EthereumAddress(string: addressString)
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? WalletAddress else { return false }
        return object.id == id
    }
}
