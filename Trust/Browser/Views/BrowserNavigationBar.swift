// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol BrowserNavigationBarDelegate: class {
    func did(action: BrowserAction)
}

class BrowserNavigationBar: UINavigationBar {

    let goBack = UIButton()
    let goForward = UIButton()
    let textField = UITextField()
    weak var browserDelegate: BrowserNavigationBarDelegate?

    private struct Layout {
        static let width: CGFloat = 34
    }

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

        goBack.translatesAutoresizingMaskIntoConstraints = false
        goBack.setImage(R.image.toolbarBack(), for: .normal)
        goBack.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)

        goForward.translatesAutoresizingMaskIntoConstraints = false
        goForward.setImage(R.image.toolbarForward(), for: .normal)
        goForward.addTarget(self, action: #selector(goForwardAction), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            goBack,
            goForward,
            textField,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),

            goForward.widthAnchor.constraint(equalToConstant: Layout.width),
            goBack.widthAnchor.constraint(equalToConstant: Layout.width),
        ])
    }

    @objc private func goBackAction() {
        browserDelegate?.did(action: .goBack)
    }

    @objc private func goForwardAction() {
        browserDelegate?.did(action: .goForward)
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
