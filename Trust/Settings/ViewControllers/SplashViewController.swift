// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import VENTouchLock

class SplashViewController: VENTouchLockSplashViewController {

    let label = UILabel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setIsSnapshot(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center

        view.addSubview(label)

        let logoImageView = UIImageView(image: R.image.launch_screen_logo())
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
        ])
        self.showUnlock(animated: true)
    }

    override func dismiss(withUnlockSuccess success: Bool, unlockType: VENTouchLockSplashViewControllerUnlockType, animated: Bool) {
        switch unlockType {
        case .passcode, .touchID:
            super.dismiss(withUnlockSuccess: success, unlockType: unlockType, animated: animated)
        case .none:
            transition(to: .error(.numberOfTries))
            dismiss(animated: false, completion: nil)
        }
    }

    override func showUnlock(animated: Bool) {
        transition(to: .new)
        if VENTouchLock.shouldUseTouchID() {
            showTouchID()
        } else {
            showPasscode(animated: animated)
        }
    }

    override func showTouchID() {

        touchLock.requestTouchID(completion: { response in
            switch response {
            case .success:
                self.dismiss(withUnlockSuccess: true, unlockType: .touchID, animated: false)
            case .usePasscode, .canceled, .promptAlreadyPresent:
                self.showPasscode(animated: false)
            case .undefined:
                self.showTouchID()
            }
        })
    }

    override func showPasscode(animated: Bool) {
        let controller = VENTouchLockEnterPasscodeViewController()
        controller.willFinishWithResult = { result in
            if result {
                self.dismiss(withUnlockSuccess: true, unlockType: .passcode, animated: false)
            }
        }
        present(controller, animated: animated, completion: nil)
    }

    func transition(to state: SplashState) {
        switch state {
        case .new:
            label.text = ""
        case .error(let error):
            label.text = error.errorDescription
        }
    }
}
