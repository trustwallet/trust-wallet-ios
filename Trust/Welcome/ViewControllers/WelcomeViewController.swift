// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import EAIntroView

protocol WelcomeViewControllerDelegate: class {
    func didPressStart(in viewController: WelcomeViewController)
}

class WelcomeViewController: UIViewController {

    private let viewModel = WelcomeViewModel()
    weak var delegate: WelcomeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let button = Button(size: .large, style: .solid)
        button.frame = CGRect(x: 0, y: 0, width: 300, height: 64)
        button.setTitle(NSLocalizedString("Welcome.GetStarted", value: "GET STARTED", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        button.layer.cornerRadius = 5
        button.backgroundColor = Colors.darkBlue

        let introView = EAIntroView(frame: self.view.frame, andPages: [
            constructPage(
                title: NSLocalizedString("Welcome.PrivateAndSecure", value: "Private & Secure", comment: ""),
                description: NSLocalizedString("Welcome.PrivateKeysNeverLeaveDevice", value: "Private keys never leave your device.", comment: ""),
                image: R.image.onboarding_lock()
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
        introView?.pageControlY = height / 4.2
        introView?.pageControl.pageIndicatorTintColor = viewModel.pageIndicatorTintColor
        introView?.pageControl.currentPageIndicatorTintColor = viewModel.currentPageIndicatorTintColor
        introView?.skipButton = button
        introView?.skipButtonY = view.frame.height / 6
        introView?.swipeToExit = false
        introView?.skipButtonAlignment = .center
        introView?.show(in: self.view, animateDuration: 0)

        button.removeTarget(introView, action: nil, for: .touchUpInside)
        button.addTarget(self, action: #selector(startFlow), for: .touchUpInside)
    }

    func constructPage(
        title: String,
        description: String,
        image: UIImage?
    ) -> EAIntroPage {
        let height = view.frame.height

        let page = EAIntroPage()
        page.title = title
        page.desc = description
        page.titleIconPositionY = height / 6
        page.descPositionY = height / 3
        page.titleFont = viewModel.pageTitleFont
        page.titleColor = viewModel.pageTitleColor
        page.descFont = viewModel.pageDescriptionFont
        page.descColor = viewModel.pageDescriptionColor
        page.titleIconView = UIImageView(image: image)
        return page
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @objc func startFlow() {
        delegate?.didPressStart(in: self)
    }
}
