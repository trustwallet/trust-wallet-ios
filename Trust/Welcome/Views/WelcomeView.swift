// Copyright SIX DAY LLC. All rights reserved.

import UIKit

final class WelcomeView: UIView {
    var model = WelcomeViewModel() {
        didSet {
            backgroundColor = model.backgroundColor
            pageControl.currentPageIndicatorTintColor = model.currentPageIndicatorTintColor
            pageControl.pageIndicatorTintColor = model.pageIndicatorTintColor
            pageControl.numberOfPages = model.numberOfPages
            pageControl.currentPage = model.currentPage
        }
    }

    var collectionContainer: UIView!
    var pageControl: UIPageControl!
    var createWalletButton: UIButton!
    var importWalletButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        collectionContainer = UIView()
        addSubview(collectionContainer)

        pageControl = UIPageControl()
        addSubview(pageControl)

        createWalletButton = Button(size: .large, style: .solid)
        createWalletButton.setTitle(NSLocalizedString("welcome.createWallet", value: "CREATE WALLET", comment: ""), for: .normal)
        addSubview(createWalletButton)

        importWalletButton = Button(size: .large, style: .solid)
        importWalletButton.setTitle(NSLocalizedString("welcome.importWallet", value: "IMPORT WALLET", comment: ""), for: .normal)
        addSubview(importWalletButton)

        NSLayoutConstraint.activate([
            collectionContainer.topAnchor.constraint(equalTo: topAnchor),
            collectionContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionContainer.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: createWalletButton.topAnchor, constant: -20),
            createWalletButton.widthAnchor.constraint(equalToConstant: 300),
            createWalletButton.heightAnchor.constraint(equalToConstant: 50),
            createWalletButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            createWalletButton.bottomAnchor.constraint(equalTo: importWalletButton.topAnchor, constant: -10),
            importWalletButton.widthAnchor.constraint(equalToConstant: 300),
            importWalletButton.heightAnchor.constraint(equalToConstant: 50),
            importWalletButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }

    func showCollectionView(_ view: UIView) {
        collectionContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionContainer.topAnchor),
            view.leadingAnchor.constraint(equalTo: collectionContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionContainer.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: collectionContainer.bottomAnchor),
        ])
    }
}
