// Copyright DApps Platform Inc. All rights reserved.

import Foundation

protocol EnterPasscodeViewModelInterface: class {
    var initialLabelText: String { get }
    var tryAfterOneMinute: String { get }
    var loginReason: String { get }
}
