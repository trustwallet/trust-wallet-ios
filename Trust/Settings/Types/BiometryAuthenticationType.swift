// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import LocalAuthentication

enum BiometryAuthenticationType {
    case touchID
    case faceID
    case none
}

extension BiometryAuthenticationType {
    var title: String {
        switch self {
        case .faceID: return "FaceID"
        case .touchID: return "Touch ID"
        case .none: return ""
        }
    }

    static var current: BiometryAuthenticationType {
        if #available(iOS 11.0, *) {
            switch LAContext().biometryType {
            case .typeTouchID: return .touchID
            case .typeFaceID: return .faceID
            case .none: return .none
            }
        }
        return .touchID
    }
}


