// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class BrowserHomeView: UIView {

    let searchBar = UITextField()
    let stackView: UIStackView
    let qrButton: UIButton

    override init(frame: CGRect) {

        let dapps = [
            DAppModel(name: "Cat", image: "https://www.cryptokitties.co/images/letterHead.png"),
            DAppModel(name: "Dog", image: "https://www.cryptokitties.co/images/letterHead.png"),
            DAppModel(name: "Kyber", image: "https://www.cryptokitties.co/images/letterHead.png"),
        ]

        qrButton = UIButton(type: .custom)
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.setImage(R.image.qr_code_icon(), for: .normal)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = Colors.gray.cgColor
        searchBar.rightView = qrButton
        searchBar.rightViewMode = .always
        searchBar.layer.cornerRadius = 5
        searchBar.layer.masksToBounds = true

        stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 100),
            searchBar,
            .spacer(height: 20),
            BrowserHomeView.header(for: "Popular"),
            BrowserHomeView.collection(dapps: dapps),
            BrowserHomeView.header(for: "Trending"),
            BrowserHomeView.collection(dapps: dapps),
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        //stackView.alignment = .center
        stackView.axis = .vertical

        super.init(frame: .zero)

        backgroundColor = .white

        addSubview(stackView)
        stackView.anchor(to: self, margin: 15)

        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 40),

            qrButton.heightAnchor.constraint(equalToConstant: 34),
            qrButton.widthAnchor.constraint(equalToConstant: 42),
//            homeView.topAnchor.constraint(equalTo: webView.topAnchor),
//            homeView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
//            homeView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
//            homeView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func header(for text: String) -> UIView {
        let label = UILabel()
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
}
