// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SettingsViewModel {

    private let isDebug: Bool

    init(
        isDebug: Bool = false
    ) {
        self.isDebug = isDebug
    }

    var servers: [RPCServer] {
        return [
            RPCServer.main,
            RPCServer.classic,
            RPCServer.poa,
            RPCServer.kovan,
            RPCServer.ropsten,
            RPCServer.sokol,
        ]
    }

    var currency: [Currency] {
        return Currency.allValues.map { $0 }
    }

    var passcodeTitle: String {
        switch BiometryAuthenticationType.current {
        case .faceID, .touchID:
            return String(
                format: NSLocalizedString("settings.biometricsEnabled.label.title", value: "Passcode / %@", comment: ""),
                BiometryAuthenticationType.current.title
            )
        case .none:
            return NSLocalizedString("settings.biometricsDisabled.label.title", value: "Passcode", comment: "")
        }
    }

    var networkTitle: String {
        return NSLocalizedString("settings.network.button.title", value: "Network", comment: "")
    }

    var currencyTitle: String {
        return NSLocalizedString("settings.currency.button.title", value: "Currency", comment: "")
    }
}
