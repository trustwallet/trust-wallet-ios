// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result
import MBProgressHUD

enum ConfirmationError: LocalizedError {
    case cancel
}

extension UIViewController {
    func displaySuccess(title: String? = .none, message: String? = .none) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func displayError(error: Error) {
        let alert = UIAlertController(title: error.prettyError, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func confirm(
        title: String? = .none,
        message: String? = .none,
        completion: @escaping (Result<Void, ConfirmationError>) -> Void
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completion(.success())
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            completion(.failure(ConfirmationError.cancel))
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    func displayLoading(text: String = "Loading...") {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = text
        hud.hide(animated: true)
    }

    func hideLoading() {
        MBProgressHUD.hide(for: view, animated: true)
    }

    func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }

    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}
