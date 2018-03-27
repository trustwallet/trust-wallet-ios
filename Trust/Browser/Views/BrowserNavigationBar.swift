// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol BrowserNavigationBarDelegate: class {
    func did(action: BrowserAction)
}

class BrowserNavigationBar: UIView {

    let goBack = UIButton()
    let goForward = UIButton()
    let textField = UITextField()
    let moreButton = UIButton()
    let homeButton = UIButton()
    let stackView = UIStackView()
    let hairLine = UIView()
    weak var browserDelegate: BrowserNavigationBarDelegate?

    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = Colors.darkBlue
        progressView.trackTintColor = .clear
        return progressView
    }()

    private struct Layout {
        static let width: CGFloat = 34
        static let moreButtonWidth: CGFloat = 24
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        hairLine.translatesAutoresizingMaskIntoConstraints = false
        hairLine.backgroundColor = Colors.lightGray

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

        goBack.translatesAutoresizingMaskIntoConstraints = false
        goBack.setImage(R.image.toolbarBack(), for: .normal)
        goBack.addTarget(self, action: #selector(goBackAction), for: .touchUpInside)

        goForward.translatesAutoresizingMaskIntoConstraints = false
        goForward.setImage(R.image.toolbarForward(), for: .normal)
        goForward.addTarget(self, action: #selector(goForwardAction), for: .touchUpInside)

        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(R.image.toolbarMenu(), for: .normal)
        moreButton.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)

        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.setImage(R.image.dapps_icon(), for: .normal)
        homeButton.addTarget(self, action: #selector(homeAction(_:)), for: .touchUpInside)

        let elements: [UIView] = [
            goBack,
            goForward,
            textField,
            .spacerWidth(),
            homeButton,
            moreButton,
        ]
        for item in elements {
            stackView.addArrangedSubview(item)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4

        addSubview(hairLine)
        addSubview(stackView)
        addSubview(progressView)
        bringSubview(toFront: progressView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -6),

            homeButton.widthAnchor.constraint(equalToConstant: Layout.width),
            goForward.widthAnchor.constraint(equalToConstant: Layout.width),
            goBack.widthAnchor.constraint(equalToConstant: Layout.width),
            moreButton.widthAnchor.constraint(equalToConstant: Layout.moreButtonWidth),

            progressView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            progressView.bottomAnchor.constraint(equalTo: hairLine.topAnchor),

            hairLine.heightAnchor.constraint(equalToConstant: 0.5),
            hairLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            hairLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            hairLine.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc private func goBackAction() {
        browserDelegate?.did(action: .goBack)
    }

    @objc private func goForwardAction() {
        browserDelegate?.did(action: .goForward)
    }

    @objc private func moreAction(_ sender: UIView) {
        browserDelegate?.did(action: .more(sender: sender))
    }

    @objc private func homeAction(_ sender: UIView) {
        browserDelegate?.did(action: .home)
    }

    func showElements(show: Bool) {
        stackView.isHidden = show
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
