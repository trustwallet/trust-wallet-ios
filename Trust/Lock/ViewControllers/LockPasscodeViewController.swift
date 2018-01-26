// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockPasscodeViewController: UIViewController {
    var invisiblePasscodeField = UITextField()
    var shouldIgnoreTextFieldDelegateCalls = false
    var willFinishWithResult: ((_ success: Bool) -> Void)?
    let model: LockViewModel
    var lockView: LockView!
    init(model: LockViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        self.view.backgroundColor = UIColor.white
        self.configureInvisiblePasscodeField()
        self.configureNavigationItems()
        self.configureLockView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !invisiblePasscodeField.isFirstResponder {
            invisiblePasscodeField.becomeFirstResponder()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if invisiblePasscodeField.isFirstResponder {
            invisiblePasscodeField.resignFirstResponder()
        }
    }
    private func configureInvisiblePasscodeField() {
        invisiblePasscodeField = UITextField()
        invisiblePasscodeField.keyboardType = .numberPad
        invisiblePasscodeField.isSecureTextEntry = true
        invisiblePasscodeField.delegate = self
        invisiblePasscodeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addSubview(invisiblePasscodeField)
    }
    private func configureNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.userTappedCancel))
    }
    private func configureLockView() {
        lockView = LockView(model)
        lockView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lockView)
        lockView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        lockView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        lockView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        lockView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
    @objc func userTappedCancel() {
        if let finish = willFinishWithResult {
            finish(false)
        }
        dismiss(animated: true, completion: nil)
    }
    @objc func enteredPasscode(_ passcode: String) {
        shouldIgnoreTextFieldDelegateCalls = false
    }
    func clearPasscode() {
        invisiblePasscodeField.text = ""
        for characterView in lockView.characters {
            characterView.isEmpty = true
        }
    }
    func finish(withResult success: Bool, animated: Bool) {
        invisiblePasscodeField.resignFirstResponder()
        if let finish = willFinishWithResult {
            finish(success)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                lockView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardSize.height).isActive = true
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LockPasscodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if shouldIgnoreTextFieldDelegateCalls {
            return false
        }
        let newString: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        let newLength: Int = newString?.count ?? 0
        if newLength > model.charCount {
            lockView.shake()
            textField.text = ""
            return false
        } else {
            for characterView in lockView.characters {
                let index: Int = lockView.characters.index(of: characterView)!
                characterView.setEmpty(index >= newLength)
            }
            return true
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if shouldIgnoreTextFieldDelegateCalls {
            return
        }
        let newString: String? = textField.text
        let newLength: Int = newString?.count ?? 0
        if newLength == model.charCount {
            shouldIgnoreTextFieldDelegateCalls = true
            textField.text = ""
            perform(#selector(self.enteredPasscode), with: newString, afterDelay: 0.3)
        }
    }
}
