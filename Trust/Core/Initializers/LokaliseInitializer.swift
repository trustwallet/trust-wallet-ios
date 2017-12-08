// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Lokalise

class LokaliseInitializer: Initializer {

    func perform() {
        Lokalise.shared.setAPIToken("472b823ae94430928f60562ef4b9f64dcf3bbbce", projectID: "3947163159df13df851b51.98101647")
        Lokalise.shared.swizzleMainBundle()
    }
}
