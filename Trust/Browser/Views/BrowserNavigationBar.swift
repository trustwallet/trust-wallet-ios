// Copyright DApps Platform Inc. All rights reserved.

import UIKit

protocol BrowserNavigationBarDelegate: class {
    func did(action: BrowserNavigation)
}

final class BrowserNavigationBar: UINavigationBar {

    let textField = UITextField()
    let moreButton = UIButton()
    let homeButton = UIButton()
    let backButton = UIButton()
    weak var browserDelegate: BrowserNavigationBarDelegate?

    private struct Layout {
        static let width: CGFloat = 34
        static let moreButtonWidth: CGFloat = 24
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        textField.translatesAutoresizingMaskIntoConstraints = false
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
        textField.placeholder = NSLocalizedString("browser.url.textfield.placeholder", value: "Search or enter website url", comment: "")
        textField.keyboardType = .webSearch

        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(R.image.toolbarMenu(), for: .normal)
        moreButton.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)

        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.setImage(R.image.browserHome(), for: .normal)
        homeButton.addTarget(self, action: #selector(homeAction(_:)), for: .touchUpInside)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(R.image.toolbarBack(), for: .normal)
        backButton.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            homeButton,
            .spacerWidth(),
            backButton,
            textField,
            .spacerWidth(),
            moreButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),

            homeButton.widthAnchor.constraint(equalToConstant: Layout.width),
            backButton.widthAnchor.constraint(equalToConstant: Layout.width),
            moreButton.widthAnchor.constraint(equalToConstant: Layout.moreButtonWidth),
        ])
    }

    @objc private func goBackAction() {
        browserDelegate?.did(action: .goBack)
    }

    @objc private func moreAction(_ sender: UIView) {
        browserDelegate?.did(action: .more(sender: sender))
    }

    @objc private func homeAction(_ sender: UIView) {
        browserDelegate?.did(action: .home)
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        browserDelegate?.did(action: .beginEditing)
    }
}
