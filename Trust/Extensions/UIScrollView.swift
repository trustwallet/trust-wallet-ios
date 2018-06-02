// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

extension UIScrollView {
    func scrollOnTop(animated: Bool = true) {
        if #available(iOS 11.0, *) {
            setContentOffset(CGPoint(x: 0, y: -adjustedContentInset.top), animated: animated)
        } else {
            setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: animated)
        }
    }
}
