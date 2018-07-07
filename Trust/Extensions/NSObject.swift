// Copyright DApps Platform Inc. All rights reserved.

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }

    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}
