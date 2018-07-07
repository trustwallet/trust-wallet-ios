// Copyright DApps Platform Inc. All rights reserved.

import Foundation

//https://gist.github.com/simme/b78d10f0b29325743a18c905c5512788
/**
 Wraps a function in a new function that will only execute the wrapped function if `delay` has passed without this function being called.

 - Parameter delay: A `DispatchTimeInterval` to wait before executing the wrapped function after last invocation.
 - Parameter queue: The queue to perform the action on. Defaults to the main queue.
 - Parameter action: A function to debounce. Can't accept any arguments.

 - Returns: A new function that will only call `action` if `delay` time passes between invocations.
 */
func debounce(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
    var currentWorkItem: DispatchWorkItem?
    return {
        currentWorkItem?.cancel()
        currentWorkItem = DispatchWorkItem { action() }
        queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
    }
}

/**
 Wraps a function in a new function that will only execute the wrapped function if `delay` has passed without this function being called.

 Accepsts an `action` with one argument.
 - Parameter delay: A `DispatchTimeInterval` to wait before executing the wrapped function after last invocation.
 - Parameter queue: The queue to perform the action on. Defaults to the main queue.
 - Parameter action: A function to debounce. Can accept one argument.
 - Returns: A new function that will only call `action` if `delay` time passes between invocations.
 */
func debounce<T>(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping ((T) -> Void)) -> (T) -> Void {
    var currentWorkItem: DispatchWorkItem?
    return { (param1: T) in
        currentWorkItem?.cancel()
        currentWorkItem = DispatchWorkItem { action(param1) }
        queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
    }
}

/**
 Wraps a function in a new function that will only execute the wrapped function if `delay` has passed without this function being called.
 Accepsts an `action` with two arguments.
 - Parameter delay: A `DispatchTimeInterval` to wait before executing the wrapped function after last invocation.
 - Parameter queue: The queue to perform the action on. Defaults to the main queue.
 - Parameter action: A function to debounce. Can accept two arguments.
 - Returns: A new function that will only call `action` if `delay` time passes between invocations.
 */
func debounce<T, U>(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping ((T, U) -> Void)) -> (T, U) -> Void {
    var currentWorkItem: DispatchWorkItem?
    return { (param1: T, param2: U) in
        currentWorkItem?.cancel()
        currentWorkItem = DispatchWorkItem { action(param1, param2) }
        queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
    }
}
