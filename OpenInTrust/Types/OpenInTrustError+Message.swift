// Copyright SIX DAY LLC. All rights reserved.

import Foundation

extension OpenInTrustError {

    public var errorDescription: String? {
        switch self {
        case .invalidContext:
            return NSLocalizedString("openintrust.error.context", value: "Extension context is invalid", comment: "")
        case .invalidProvider:
            return NSLocalizedString("openintrust.error.provider", value: "Extension item provider is invalid", comment: "")
        case .invalidURL:
            return NSLocalizedString("openintrust.error.url", value: "Can't find valid url", comment: "")
        case .loadItemFailed:
            return NSLocalizedString("openintrust.error.loadItem", value: "Can't find valid url", comment: "")
        case .cancel:
            return NSLocalizedString("openintrust.error.cancel", value: "Canceled by user", comment: "")
        }
    }
}
