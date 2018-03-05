// Copyright SIX DAY LLC. All rights reserved.

import Foundation

public func dispatch_main_safe(block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
