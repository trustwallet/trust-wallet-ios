// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol BrowserHomeViewDelegate: class {
    func didPressQrCode()
    func didPressSearch()
}

class BrowserHomeView: UIView {

    let imageView = UIImageView()
    let searchBar = UITextField()
    let stackView: UIStackView
    let titleLabel = UILabel()
    let qrButton: UIButton

    weak var delegate: BrowserHomeViewDelegate?

    override init(frame: CGRect) {

        let dapps = [
            DAppModel(name: "Cat", image: "https://www.cryptokitties.co/images/letterHead.png"),
            DAppModel(name: "Dog", image: "https://www.cryptokitties.co/images/letterHead.png"),
            DAppModel(name: "Kyber", image: "https://www.cryptokitties.co/images/letterHead.png"),
            DAppModel(name: "Bancor", image: "https://www.cryptokitties.co/images/letterHead.png"),
        ]

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = R.image.launch_screen_logo()
        imageView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "TRUST"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        titleLabel.textColor = Colors.darkBlue

        qrButton = UIButton(type: .custom)
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.setImage(R.image.scan(), for: .normal)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.borderColor = Colors.lightGray.cgColor
        searchBar.leftView = .spacerWidth(8)
        searchBar.leftViewMode = .always
        searchBar.rightView = qrButton
        searchBar.rightViewMode = .always
        searchBar.layer.cornerRadius = 5
        searchBar.layer.masksToBounds = true
        searchBar.placeholder = NSLocalizedString("browser.home.search.placeholder", value: "Search & enter dApp URL", comment: "")

        stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 20),
            imageView,
            .spacer(height: 0),
            titleLabel,
            .spacer(height: 30),
            searchBar,
            .spacer(height: 20),
            BrowserHomeView.header(for: "dApp of Today"),
            BrowserHomeView.collection(dapps: dapps),
            BrowserHomeView.collection(dapps: dapps),
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        super.init(frame: .zero)

        backgroundColor = .white
        addSubview(stackView)

        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 40),

            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),

            qrButton.heightAnchor.constraint(equalToConstant: 36),
            qrButton.widthAnchor.constraint(equalToConstant: 36),

            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
        ])

        searchBar.delegate = self
        qrButton.addTarget(self, action: #selector(qrCode), for: .touchUpInside)
    }

    @objc func qrCode() {
        delegate?.didPressQrCode()
    }

    private static func header(for text: String) -> UIView {
        let label = UILabel()
        label.textColor = Colors.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }

    private static func collection(dapps: [DAppModel]) -> DAppCollectionView {
        let popularCollectionView = DAppCollectionView()
        popularCollectionView.translatesAutoresizingMaskIntoConstraints = false
        popularCollectionView.elements = dapps
        return popularCollectionView
    }

    func update(_ dapps: DAppsBootstrap) {
        //
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrowserHomeView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.didPressSearch()
        return false
    }
}
