// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UIActivityViewController {
    static func make(items: [Any]) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
}
