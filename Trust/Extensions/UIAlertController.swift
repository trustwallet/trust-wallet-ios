// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

extension UIAlertController {

    static func askPassword(
        title: String = "",
        message: String = "",
        completion: @escaping (Result<String, ConfirmationError>) -> Void
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", value: "OK", comment: ""), style: .default, handler: { _ -> Void in
            let textField = alertController.textFields![0] as UITextField
            let password = textField.text ?? ""
            completion(.success(password))
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel, handler: { _ in
            completion(.failure(ConfirmationError.cancel))
        }))
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = NSLocalizedString("Password", value: "Password", comment: "")
            textField.isSecureTextEntry = true
        })
        return alertController
    }
}
