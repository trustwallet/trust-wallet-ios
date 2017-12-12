// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SendInputErrors: LocalizedError {
    case emptyClipBoard
    case invalidAddress
    case wrongInput

    var errorDescription: String? {
        switch self {
        case .emptyClipBoard:
            return NSLocalizedString("send.error.emptyClipBoard", value: "Empty ClipBoard", comment: "")
        case .invalidAddress:
            return NSLocalizedString("send.error.invalidAddress", value: "Invalid Address", comment: "")
        case .wrongInput:
            return NSLocalizedString("send.error.wrongInput", value: "Wrong Input", comment: "")
        }
    }
}
