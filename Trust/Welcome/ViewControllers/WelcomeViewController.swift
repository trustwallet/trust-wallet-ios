// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol WelcomeViewControllerDelegate: class {
    func didPressCreateWallet(in viewController: WelcomeViewController)
    func didPressImportWallet(in viewController: WelcomeViewController)
}

class WelcomeViewController: UIViewController {

    var viewModel = WelcomeViewModel()
    weak var delegate: WelcomeViewControllerDelegate?

    lazy var collectionViewController: OnboardingCollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        let collectionViewController = OnboardingCollectionViewController(collectionViewLayout: layout)
        collectionViewController.pages = pages
        collectionViewController.pageControl = pageControl
        collectionViewController.collectionView?.isPagingEnabled = true
        collectionViewController.collectionView?.showsHorizontalScrollIndicator = false
        collectionViewController.collectionView?.backgroundColor = viewModel.backgroundColor
        return collectionViewController
    }()
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    let createWalletButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("welcome.createWallet.button.title", value: "CREATE WALLET", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        button.backgroundColor = Colors.darkBlue
        return button
    }()
    let importWalletButton: UIButton = {
        let importWalletButton = Button(size: .large, style: .border)
        importWalletButton.translatesAutoresizingMaskIntoConstraints = false
        importWalletButton.setTitle(NSLocalizedString("welcome.importWallet.button.title", value: "IMPORT WALLET", comment: ""), for: .normal)
        importWalletButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        importWalletButton.accessibilityIdentifier = "import-wallet"
        return importWalletButton
    }()
    let pages: [OnboardingPageViewModel] = [
        OnboardingPageViewModel(
            title: NSLocalizedString("welcome.privateAndSecure.label.title", value: "Private & Secure", comment: ""),
            subtitle: NSLocalizedString("welcome.privateAndSecure.label.description", value: "Private keys never leave your device.", comment: ""),
            image: R.image.onboarding_lock()!
        ),
        OnboardingPageViewModel(
            title: NSLocalizedString("welcome.erc20.label.title", value: "ERC20 Compatible", comment: ""),
            subtitle: NSLocalizedString("welcome.erc20.label.description", value: "Support for ERC20 tokens by default. ", comment: ""),
            image: R.image.onboarding_erc20()!
        ),
        OnboardingPageViewModel(
            title: NSLocalizedString("welcome.fullyTransparent.label.title", value: "Fully transparent", comment: ""),
            subtitle: NSLocalizedString("welcome.fullyTransparent.label.description", value: "Code is open sourced (GPL-3.0 license) and fully audited.", comment: ""),
            image: R.image.onboarding_open_source()!
        ),
        OnboardingPageViewModel(
            title: NSLocalizedString("welcome.ultraReliable.label.title", value: "Ultra Reliable", comment: ""),
            subtitle: NSLocalizedString("welcome.ultraReliable.label.description", value: "The fastest Ethereum wallet experience on mobile", comment: ""),
            image: R.image.onboarding_rocket()!
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.numberOfPages = pages.count
        view.addSubview(collectionViewController.view)

        let stackView = UIStackView(arrangedSubviews: [
            pageControl,
            createWalletButton,
            importWalletButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        view.addSubview(stackView)

        collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            collectionViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stackView.topAnchor.constraint(equalTo: collectionViewController.view.centerYAnchor, constant: 120),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),

            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

            createWalletButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            createWalletButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            importWalletButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            importWalletButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])

        createWalletButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        importWalletButton.addTarget(self, action: #selector(importFlow), for: .touchUpInside)

        configure(viewModel: viewModel)
    }

    func configure(viewModel: WelcomeViewModel) {
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        pageControl.currentPageIndicatorTintColor = viewModel.currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = viewModel.pageIndicatorTintColor
        pageControl.numberOfPages = viewModel.numberOfPages
        pageControl.currentPage = viewModel.currentPage
    }

    @IBAction func start() {
        delegate?.didPressCreateWallet(in: self)
    }

    @IBAction func importFlow() {
        delegate?.didPressImportWallet(in: self)
    }
}
