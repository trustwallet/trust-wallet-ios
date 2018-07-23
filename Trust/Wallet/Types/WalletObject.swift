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
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var addressString: String = ""
    @objc private dynamic var rawCoin = -1
    public var coin: Coin {
        get { return Coin(rawValue: rawCoin) ?? .ethereum }
        set { rawCoin = newValue.rawValue }
    }

    convenience init(
        coin: Coin,
        address: Address
    ) {
        self.init()
        self.addressString = address.description
        self.coin = coin
    }

    var address: EthereumAddress? {
        return EthereumAddress(string: addressString)
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["coin"]
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? WalletAddress else { return false }
        return object.address == address
    }
}
