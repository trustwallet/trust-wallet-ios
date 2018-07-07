// Copyright DApps Platform Inc. All rights reserved.

import Foundation

open class Subscribable<T> {
    private var _value: T?
    private var _subscribers: [(T?) -> Void] = []
    open var value: T? {
        get {
            return _value
        }
        set {
            _value = newValue
            for f in _subscribers {
                f(value)
            }
        }
    }

    public init(_ value: T?) {
        _value = value
    }

    open func subscribe(_ subscribe: @escaping (T?) -> Void) {
        if let value = _value {
            subscribe(value)
        }
        _subscribers.append(subscribe)
    }
}
