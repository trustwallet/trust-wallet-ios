// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct CastError<ExpectedType>: Error {
    let actualValue: Any
    let expectedType: ExpectedType.Type
}
