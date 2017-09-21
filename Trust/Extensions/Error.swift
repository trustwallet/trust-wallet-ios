// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation

extension Error {
    var prettyError: String {
        switch self {
        case let error as LocalizedError:
            return error.errorDescription ?? "An unknown error occurred."
        case let error as NSError:
            return error.localizedDescription
        default:
            return "Undefined Error"
        }
    }
}
