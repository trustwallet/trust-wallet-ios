// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UIActivityViewController {
    static func makeShareController(items: [Any]) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
}
