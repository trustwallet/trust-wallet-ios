// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

extension NSLocale {
    static var preferredLanguageCode: String? {
        let langageRegion = NSLocale.preferredLanguages.first ?? ""
        let languageComponents = NSLocale.components(fromLocaleIdentifier: langageRegion)
        return languageComponents[NSLocale.Key.languageCode.rawValue]
    }
}
