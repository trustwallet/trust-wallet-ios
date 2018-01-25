// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol BrowserNavigationBarDelegate: class {
    func did(action: BrowserAction)
}

class BrowserNavigationBar: UINavigationBar {

    let toolbar = UIToolbar(frame: .zero)
    let textField = UITextField()
    let goBackItem = UIBarButtonItem(image: R.image.toolbarBack(), style: .done, target: self, action: #selector(goBack))
    let goForwardItem = UIBarButtonItem(image: R.image.toolbarForward(), style: .done, target: self, action: #selector(goForward))

    weak var browserDelegate: BrowserNavigationBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .URL
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = Colors.lightGray.cgColor
        textField.autocapitalizationType = .none
        textField.autoresizingMask = .flexibleWidth
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.returnKeyType = .go
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 30))
        textField.leftViewMode = .always
        textField.autoresizingMask = [.flexibleWidth]
        textField.setContentHuggingPriority(.required, for: .horizontal)

        let textfieldItem = UIBarButtonItem(customView: textField)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.items = [
            goBackItem,
            goForwardItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            textfieldItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
        addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    @objc private func goBack() {
        browserDelegate?.did(action: .back)
    }

    @objc private func goForward() {
        browserDelegate?.did(action: .forward)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrowserNavigationBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        browserDelegate?.did(action: .enter(textField.text ?? ""))
        textField.resignFirstResponder()
        return true
    }
}
