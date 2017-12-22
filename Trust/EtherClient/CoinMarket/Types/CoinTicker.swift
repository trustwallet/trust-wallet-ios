// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct CoinTicker {
    let id:String
    let name:String
    let symbol:String
    let rank:String
    let usdPrice:String
    let btcPrice:String
    let volumeUsd24h:String?
    let marketCapUsd:String?
    let availableSupply:String?
    let totalSupply:String?
    let percentChange1h:String?
    let percentChange24h:String?
    let percentChange7d:String?
    let lastUpdated:String
    let img:String
    
    static let path = "https://files.coinmarketcap.com/static/img/coins/32x32/"
}

extension CoinTicker: Decodable {
    
    enum CoinTickerKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case symbol = "symbol"
        case rank = "rank"
        case usdPrice = "price_usd"
        case btcPrice = "price_btc"
        case volumeUsd24h = "24h_volume_usd"
        case marketCapUsd = "market_cap_usd"
        case availableSupply = "available_supply"
        case totalSupply = "total_supply"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case percentChange7d = "percent_change_7d"
        case lastUpdated = "last_updated"
        case img = "img"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CoinTickerKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let name: String = try container.decode(String.self, forKey: .name)
        let symbol: String = try container.decode(String.self, forKey: .symbol)
        let rank: String = try container.decode(String.self, forKey: .rank)
        let usdPrice: String = try container.decode(String.self, forKey: .usdPrice)
        let btcPrice: String = try container.decode(String.self, forKey: .btcPrice)
        let volumeUsd24h: String? = try container.decodeIfPresent(String.self, forKey: .volumeUsd24h)
        let marketCapUsd: String? = try container.decodeIfPresent(String.self, forKey: .marketCapUsd)
        let availableSupply: String? = try container.decodeIfPresent(String.self, forKey: .availableSupply)
        let totalSupply: String? = try container.decodeIfPresent(String.self, forKey: .totalSupply)
        let percentChange1h: String? = try container.decodeIfPresent(String.self, forKey: .percentChange1h)
        let percentChange24h: String? = try container.decodeIfPresent(String.self, forKey: .percentChange24h)
        let percentChange7d: String? = try container.decodeIfPresent(String.self, forKey: .percentChange7d)
        let lastUpdated: String = try container.decode(String.self, forKey: .lastUpdated)
        let img: String = CoinTicker.path + id + ".png"
        
        self.init(id: id, name: name, symbol: symbol, rank: rank, usdPrice: usdPrice, btcPrice: btcPrice, volumeUsd24h: volumeUsd24h, marketCapUsd: marketCapUsd, availableSupply: availableSupply, totalSupply: totalSupply, percentChange1h: percentChange1h, percentChange24h: percentChange24h, percentChange7d: percentChange7d, lastUpdated: lastUpdated, img: img)
    }
}

class RealmCoinTicker: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var rank: String = ""
    @objc dynamic var usdPrice: String = ""
    @objc dynamic var btcPrice: String = ""
    @objc dynamic var volumeUsd24h: String = ""
    @objc dynamic var marketCapUsd: String = ""
    @objc dynamic var availableSupply: String = ""
    @objc dynamic var totalSupply: String = ""
    @objc dynamic var percentChange1h: String = ""
    @objc dynamic var percentChange24h: String = ""
    @objc dynamic var percentChange7d: String = ""
    @objc dynamic var lastUpdated: String = ""
    @objc dynamic var img: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(coin: CoinTicker) {
        self.init()
        id = coin.id
        name = coin.name
        symbol = coin.symbol
        rank = coin.rank
        usdPrice = coin.usdPrice
        btcPrice = coin.btcPrice
        volumeUsd24h = coin.volumeUsd24h ?? ""
        marketCapUsd = coin.marketCapUsd ?? ""
        availableSupply = coin.availableSupply ?? ""
        totalSupply = coin.totalSupply ?? ""
        percentChange1h = coin.percentChange1h ?? ""
        percentChange24h = coin.percentChange24h ?? ""
        percentChange7d = coin.percentChange7d ?? ""
        lastUpdated = coin.lastUpdated
        img = coin.img
    }
    
    var entity: CoinTicker {
        return CoinTicker(id: id, name: name, symbol: symbol, rank: rank, usdPrice: usdPrice, btcPrice: btcPrice, volumeUsd24h: volumeUsd24h, marketCapUsd: marketCapUsd, availableSupply: availableSupply, totalSupply: totalSupply, percentChange1h: percentChange1h, percentChange24h: percentChange24h, percentChange7d: percentChange7d, lastUpdated: lastUpdated, img: img)
    }
}
