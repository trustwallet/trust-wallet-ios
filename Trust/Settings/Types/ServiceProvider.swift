// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum URLServiceProvider {
    case twitter
    case telegram
    case facebook

    var title: String {
        switch self {
        case .twitter: return "Twitter"
        case .telegram: return "Telegram Group"
        case .facebook: return "Facebook"
        }
    }

    var localURL: URL? {
        switch self {
        case .twitter:
            return URL(string: "twitter://user?screen_name=\(Constants.twitterUsername)")!
        case .telegram:
            return URL(string: "tg:resolve?domain=\(Constants.telegramUsername)")
        case .facebook:
            return URL(string: "fb://profile/\(Constants.facebookUsername)")
        }
    }

    var remoteURL: URL {
        return URL(string: self.remoteURLString)!
    }

    private var remoteURLString: String {
        switch self {
        case .twitter:
            return "https://twitter.com/\(Constants.twitterUsername)"
        case .telegram:
            return "https://telegram.me/\(Constants.telegramUsername)"
        case .facebook:
            return "https://www.facebook.com/\(Constants.facebookUsername)"
        }
    }

    var image: UIImage? {
        switch self {
        case .twitter: return R.image.settings_twitter()
        case .telegram: return R.image.settings_telegram()
        case .facebook: return R.image.settings_facebook()
        }
    }
}
