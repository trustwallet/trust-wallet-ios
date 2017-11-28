// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol WelcomeViewControllerDelegate: class {
    func didPressCreateWallet(in viewController: WelcomeViewController)
    func didPressImportWallet(in viewController: WelcomeViewController)
}

class WelcomeViewController: UIViewController {

    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var createWalletButton: UIButton!
    @IBOutlet private weak var importWalletButton: UIButton!

    private let viewModel = WelcomeViewModel()
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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        pageControl.numberOfPages = pages.count

        createWalletButton.setTitle(NSLocalizedString("welcome.createWallet", value: "CREATE WALLET", comment: ""), for: .normal)
        importWalletButton.setTitle(NSLocalizedString("welcome.importWallet", value: "IMPORT WALLET", comment: ""), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let collectionViewController = segue.destination as? OnboardingCollectionViewController else {
            return
        }
        collectionViewController.pages = pages
        collectionViewController.pageControl = pageControl
    }

    @IBAction func start() {
        delegate?.didPressCreateWallet(in: self)
    }

    @IBAction func importFlow() {
        delegate?.didPressImportWallet(in: self)
    }
}
