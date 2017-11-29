// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol WelcomeViewControllerDelegate: class {
    func didPressCreateWallet(in viewController: WelcomeViewController)
    func didPressImportWallet(in viewController: WelcomeViewController)
}

class WelcomeViewController: UIViewController {
    var welcomeView: WelcomeView {
        return view as! WelcomeView
    }

    var viewModel = WelcomeViewModel()
    weak var delegate: WelcomeViewControllerDelegate?

    let pages: [OnboardingPageViewModel] = [
        OnboardingPageViewModel(
            title: NSLocalizedString("Welcome.PrivateAndSecure", value: "Private & Secure", comment: ""),
            subtitle: NSLocalizedString("Welcome.PrivateKeysNeverLeaveDevice", value: "Private keys never leave your device.", comment: ""),
            image: R.image.onboarding_lock()!
        ),
        OnboardingPageViewModel(
            title: NSLocalizedString("welcome.erc20title", value: "ERC20 Compatible", comment: ""),
            subtitle: NSLocalizedString("welcome.erc20description", value: "Support for ERC20 tokens by default. ", comment: ""),
            image: R.image.onboarding_erc20()!
        ),
        OnboardingPageViewModel(
            title: NSLocalizedString("Welcome.FullyTransparent", value: "Fully transparent", comment: ""),
            subtitle: NSLocalizedString("Welcome.CodeOpenSource", value: "Code is open sourced (GPL-3.0 license) and fully audited.", comment: ""),
            image: R.image.onboarding_open_source()!
        ),
        OnboardingPageViewModel(
            title: NSLocalizedString("Welcome.UltraReliable", value: "Ultra Reliable", comment: ""),
            subtitle: NSLocalizedString("Welcome.FastExperience", value: "The fastest Ethereum wallet experience on mobile", comment: ""),
            image: R.image.onboarding_rocket()!
        ),
    ]

    override func loadView() {
        viewModel.numberOfPages = pages.count
        view = WelcomeView()
        welcomeView.model = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal

        let collectionViewController = OnboardingCollectionViewController(collectionViewLayout: layout)
        collectionViewController.pages = pages
        collectionViewController.pageControl = welcomeView.pageControl
        addChildViewController(collectionViewController)
        welcomeView.showCollectionView(collectionViewController.view)

        welcomeView.createWalletButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        welcomeView.importWalletButton.addTarget(self, action: #selector(importFlow), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }

    @IBAction func start() {
        delegate?.didPressCreateWallet(in: self)
    }

    @IBAction func importFlow() {
        delegate?.didPressImportWallet(in: self)
    }
}
