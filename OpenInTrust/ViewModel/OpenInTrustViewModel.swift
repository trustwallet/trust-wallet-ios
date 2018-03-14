// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import MobileCoreServices
import Result

typealias TrustItemProvider = (provider: NSItemProvider, type: String)

struct OpenInTrustViewModel {
    let context: NSExtensionContext

    init(context: NSExtensionContext) {
        self.context = context
    }

    var confirmAlertTitle: String {
        return NSLocalizedString("openintrust.alert.title.confirm", value: "Open In Trust", comment: "")
    }

    var confirmAlertMessage: String {
        return NSLocalizedString("openintrust.alert.msg.confirm", value: "Browsing %@ with Trust Dapps Browser", comment: "")
    }

    var errorAlertTitle: String {
        return NSLocalizedString("openintrust.alert.title.error", value: "Error", comment: "")
    }

    var alertOK: String {
        return NSLocalizedString("openintrust.alert.button.ok", value: "OK", comment: "")
    }

    var alertCancel: String {
        return NSLocalizedString("openintrust.alert.button.cancel", value: "Cancel", comment: "")
    }

    func findItemProvider() -> TrustItemProvider? {
        var urlProvider: NSItemProvider?
        var textProvider: NSItemProvider?
        for item in context.inputItems {
            guard let inputItem = item as? NSExtensionItem,
                let attachments = inputItem.attachments as? [NSItemProvider] else {
                    continue
            }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    urlProvider = provider
                } else if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    textProvider = provider
                }
            }
        }

        var validItemProvider: NSItemProvider?
        var typeIdentifier: String?
        if urlProvider != nil {
            validItemProvider = urlProvider
            typeIdentifier = kUTTypeURL as String
        } else if textProvider != nil {
            validItemProvider = urlProvider
            typeIdentifier = kUTTypeText as String
        }

        guard let provider = validItemProvider,
            let type = typeIdentifier else {
                return nil
        }
        return (provider: provider, type: type)
    }

    func loadItem(provider: TrustItemProvider, completion: @escaping (Result<URL, OpenInTrustError>) -> Void) {
        provider.provider.loadItem(forTypeIdentifier: provider.type, options: nil) { (item, error) in
            guard error == nil else {
                return completion(Result.init(error: OpenInTrustError.loadItemFailed))
            }
            // try URL first
            var url = item as? URL
            if url == nil {
                // then try text
                if let text = item as? String {
                    url = URL(string: text)
                }
            }
            guard let validUrl = url else {
                return completion(Result.init(error: OpenInTrustError.invalidURL))
            }
            completion(Result.init(value: validUrl))
        }
    }
}
