// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SendInputErrors: LocalizedError {
    case emptyClipBoard
    case invalidAddress

    var errorDescription: String? {
        switch self {
        case .emptyClipBoard:
            return NSLocalizedString("send.emptyClipBoard", value: "Empty ClipBoard", comment: "")
        case .invalidAddress:
            return NSLocalizedString("send.invalidAddress", value: "Invalid Address", comment: "")
        }
    }
}
