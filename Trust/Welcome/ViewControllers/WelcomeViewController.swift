// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import EAIntroView

protocol WelcomeViewControllerDelegate: class {
    func didPressCreateWallet(in viewController: WelcomeViewController)
    func didPressImportWallet(in viewController: WelcomeViewController)
}

class WelcomeViewController: UIViewController {

    private let viewModel = WelcomeViewModel()
    weak var delegate: WelcomeViewControllerDelegate?

    lazy var getStartedButton: UIButton = {
        let getStartedButton = Button(size: .large, style: .solid)
        getStartedButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        getStartedButton.setTitle(NSLocalizedString("welcome.createWallet", value: "CREATE WALLET", comment: ""), for: .normal)
        getStartedButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        getStartedButton.layer.cornerRadius = 5
        getStartedButton.backgroundColor = Colors.darkBlue
        return getStartedButton
    }()

    lazy var importButton: UIButton = {
        let importButton = Button(size: .large, style: .solid)
        importButton.frame = CGRect(x: 0, y: 60, width: 300, height: 50)
        importButton.setTitle(NSLocalizedString("welcome.importWallet", value: "IMPORT WALLET", comment: ""), for: .normal)
        importButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        importButton.layer.cornerRadius = 5
        importButton.setBackgroundColor(Colors.gray, forState: .normal)
        importButton.setBackgroundColor(Colors.lightGray, forState: .highlighted)
        return importButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let skipPlaceholder = UIButton()
        skipPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        skipPlaceholder.frame = CGRect(x: 0, y: 0, width: 300, height: 110)
        skipPlaceholder.backgroundColor = .clear
        skipPlaceholder.isAccessibilityElement = false

        NSLayoutConstraint.activate([
            skipPlaceholder.heightAnchor.constraint(equalToConstant: 110),
        ])

        skipPlaceholder.addSubview(getStartedButton)
        skipPlaceholder.addSubview(importButton)

        let introView = EAIntroView(frame: self.view.frame, andPages: [
            constructPage(
                title: NSLocalizedString("Welcome.PrivateAndSecure", value: "Private & Secure", comment: ""),
                description: NSLocalizedString("Welcome.PrivateKeysNeverLeaveDevice", value: "Private keys never leave your device.", comment: ""),
                image: R.image.onboarding_lock()
            ),
            constructPage(
                title: NSLocalizedString("welcome.erc20title", value: "ERC20 Compatible", comment: ""),
                description: NSLocalizedString("welcome.erc20description", value: "Support for ERC20 tokens by default. ", comment: ""),
                image: R.image.onboarding_erc20()
            ),
            constructPage(
                title: NSLocalizedString("Welcome.FullyTransparent", value: "Fully transparent", comment: ""),
                description: NSLocalizedString("Welcome.CodeOpenSource", value: "Code is open sourced (GPL-3.0 license) and fully audited.", comment: ""),
                image: R.image.onboarding_open_source()
            ),
            constructPage(
                title: NSLocalizedString("Welcome.UltraReliable", value: "Ultra Reliable", comment: ""),
                description: NSLocalizedString("Welcome.FastExperience", value: "The fastest Ethereum wallet experience on mobile", comment: ""),
                image: R.image.onboarding_rocket()
            ),
        ])
        let height = view.frame.height
        introView?.backgroundColor = .white
        introView?.pageControlY = height / 3.6
        introView?.pageControl.pageIndicatorTintColor = viewModel.pageIndicatorTintColor
        introView?.pageControl.currentPageIndicatorTintColor = viewModel.currentPageIndicatorTintColor
        introView?.skipButton = skipPlaceholder
        introView?.skipButtonY = view.frame.height / 4.7
        introView?.swipeToExit = false
        introView?.skipButtonAlignment = .center
        introView?.show(in: self.view, animateDuration: 0)

        getStartedButton.removeTarget(introView, action: nil, for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(start), for: .touchUpInside)

        importButton.removeTarget(introView, action: nil, for: .touchUpInside)
        importButton.addTarget(self, action: #selector(importFlow), for: .touchUpInside)

        skipPlaceholder.removeTarget(introView, action: nil, for: .touchUpInside)
    }

    func constructPage(
        title: String,
        description: String,
        image: UIImage?
    ) -> EAIntroPage {
        let height = view.frame.height
        let titleIconPositionY = height <= 568 ? height / 8.6 : height / 5.6
        let descPositionY = height <= 568 ? height / 2.7 : height / 2.6

        let page = EAIntroPage()
        page.title = title
        page.desc = description
        page.titleIconPositionY = titleIconPositionY
        page.descPositionY = descPositionY
        page.titleFont = viewModel.pageTitleFont
        page.titleColor = viewModel.pageTitleColor
        page.descFont = viewModel.pageDescriptionFont
        page.descColor = viewModel.pageDescriptionColor
        page.titleIconView = UIImageView(image: image)
        return page
    }

    @objc func start() {
        delegate?.didPressCreateWallet(in: self)
    }

    @objc func importFlow() {
        delegate?.didPressImportWallet(in: self)
    }
}
