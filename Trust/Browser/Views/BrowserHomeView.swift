// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum HomeAction {
    case qrCode
    case search
    case endSearch
    case select(DAppModel)
}

protocol BrowserHomeViewDelegate: class {
    func didCall(action: HomeAction)
}

class BrowserHomeView: UIView {

    let imageView = UIImageView()
    let searchBar = UITextField()
    let stackView: UIStackView
    let titleLabel = UILabel()
    let qrButton: UIButton
    lazy var collectionView: DAppCollectionView = {
        let collectionView: DAppCollectionView = BrowserHomeView.collection(dapps: [])
        collectionView.delegate = self
        return collectionView
    }()

    weak var delegate: BrowserHomeViewDelegate?

    override init(frame: CGRect) {

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
        qrButton.setImage(R.image.qr_code_icon(), for: .normal)

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

            qrButton.heightAnchor.constraint(equalToConstant: 34),
            qrButton.widthAnchor.constraint(equalToConstant: 42),

            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
        ])

        searchBar.delegate = self
        qrButton.addTarget(self, action: #selector(qrCode), for: .touchUpInside)
    }

    @objc func qrCode() {
        delegate?.didCall(action: .qrCode)
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
        stackView.removeArrangedSubview(collectionView)
        collectionView.elements = dapps.new
        stackView.addArrangedSubview(collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrowserHomeView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.didCall(action: .search)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didCall(action: .endSearch)
    }
}

extension BrowserHomeView: DAppCollectionViewDelegate {
    func didSelect(dapp: DAppModel) {
        delegate?.didCall(action: .select(dapp))
    }
}
