// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit
import Result

enum ConfirmationError: LocalizedError {
    case cancel
}

extension UIViewController {
    func displayError(error: LocalizedError) {
        let alert = UIAlertController(title: error.errorDescription, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func confirm(
        title: String? = .none,
        message: String? = .none,
        completion: @escaping (Result<Void, ConfirmationError>) -> Void
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            completion(.success())
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completion(.failure(ConfirmationError.cancel))
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}
