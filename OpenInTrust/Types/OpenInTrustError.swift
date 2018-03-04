// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum OpenInTrustError: Error {
    case invalidContext
    case invalidProvider
    case invalidURL
    case loadItemFailed
    case cancel
}
