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
    let collectionView: DAppCollectionView

    let tableView: DAppsTableView

    weak var delegate: BrowserHomeViewDelegate?

    override init(frame: CGRect) {

        tableView = DAppsTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        collectionView = BrowserHomeView.collection(dapps: [])
        collectionView.translatesAutoresizingMaskIntoConstraints = false

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
        qrButton.imageView?.contentMode = .scaleAspectFit
        qrButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.borderColor = Colors.lightGray.cgColor
        searchBar.leftView = .spacerWidth(8)
        searchBar.leftViewMode = .always
        searchBar.rightView = qrButton
        searchBar.rightViewMode = .always
        searchBar.layer.cornerRadius = 5
        searchBar.layer.masksToBounds = true
        searchBar.placeholder = NSLocalizedString("browser.home.search.placeholder", value: "Search & Enter DApp URL", comment: "")

        stackView = UIStackView(arrangedSubviews: [
            BrowserHomeView.header(for: "DApp of Today", aligment: .center),
            .spacer(height: 6),
            tableView,
            .spacer(height: 25),
            searchBar,
            .spacer(height: 4),
            BrowserHomeView.header(for: "Explore decentralized web", aligment: .center),
            .spacer(height: 25),
            .spacer(height: 6),
            collectionView,
            BrowserHomeView.more(title: "More"),
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

            qrButton.heightAnchor.constraint(equalToConstant: 32),
            qrButton.widthAnchor.constraint(equalToConstant: 42),

            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
        ])

        searchBar.delegate = self
        tableView.dappsDelegate = self
        collectionView.delegate = self
        qrButton.addTarget(self, action: #selector(qrCode), for: .touchUpInside)
    }

    @objc func qrCode() {
        delegate?.didCall(action: .qrCode)
    }

    private static func more(title: String) -> UIView {
        let button = Button(size: .small, style: .borderless)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        button.titleLabel?.textColor = Colors.lightGray
        return button
    }

    private static func header(for text: String, aligment: NSTextAlignment = .left) -> UIView {
        let label = UILabel()
        label.textColor = Colors.gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = aligment
        return label
    }

    private static func collection(dapps: [DAppModel]) -> DAppCollectionView {
        let popularCollectionView = DAppCollectionView()
        popularCollectionView.translatesAutoresizingMaskIntoConstraints = false
        popularCollectionView.elements = dapps
        return popularCollectionView
    }

    func update(_ dapps: DAppsBootstrap) {
        collectionView.elements = dapps.new
        tableView.dapps = dapps.new
        tableView.invalidateIntrinsicContentSize()
        collectionView.invalidateIntrinsicContentSize()
        stackView.invalidateIntrinsicContentSize()
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
    func didSelect(dapp: DAppModel, in view: DAppCollectionView) {
        delegate?.didCall(action: .select(dapp))
    }
}

extension BrowserHomeView: DAppsTableViewDelegate {
    func didSelect(dapp: DAppModel, in view: DAppsTableView) {
        delegate?.didCall(action: .select(dapp))
    }
}
