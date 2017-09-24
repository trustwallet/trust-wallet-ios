// Copyright SIX DAY LLC, Inc. All rights reserved.

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
        button.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        button.setTitle("GET STARTED", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        button.layer.cornerRadius = 5
        button.backgroundColor = Colors.darkBlue

        let introView = EAIntroView(frame: self.view.frame, andPages: [
            constructPage(
                title: "Private & Secure",
                description: "Private keys never leave your device.",
                image: R.image.onboarding_lock()
            ),
            constructPage(
                title: "Fully transparent",
                description: "Code is open sourced (MIT licence) and fully audited.",
                image: R.image.onboarding_rocket()
            ),
            constructPage(
                title: "Ultra Reliable",
                description: "The fastest Ethereum wallet experience on mobile",
                image: R.image.onboarding_rocket()
            ),
        ])
        introView?.backgroundColor = .white
        introView?.pageControlY = 130
        introView?.pageControl.pageIndicatorTintColor = viewModel.pageIndicatorTintColor
        introView?.pageControl.currentPageIndicatorTintColor = viewModel.currentPageIndicatorTintColor
        introView?.skipButton = button
        introView?.skipButtonY = 80
        introView?.swipeToExit = false
        introView?.skipButtonAlignment = .center
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 0)

        button.removeTarget(introView, action: nil, for: .touchUpInside)
        button.addTarget(self, action: #selector(startFlow), for: .touchUpInside)
    }

    func constructPage(
        title: String,
        description: String,
        image: UIImage?
    ) -> EAIntroPage {
        let page = EAIntroPage()
        page.title = title
        page.desc = description
        page.titleIconPositionY = 70
        page.descPositionY = 200
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

extension WelcomeViewController: EAIntroDelegate {
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {

    }

    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {

    }
}
