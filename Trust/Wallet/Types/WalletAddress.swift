// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

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
        return object.address == address && object.coin == address?.coin
    }
}
