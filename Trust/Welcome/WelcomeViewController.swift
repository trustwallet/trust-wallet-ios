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
        button.setTitle("Get Started", for: .normal)

        button.layer.cornerRadius = 5

        let introView = EAIntroView(frame: self.view.frame, andPages: [
            constructPage(
                title: "Private and Secure",
                description: "Private keys never leave your device.",
                image: R.image.lock()
            ),
            constructPage(
                title: "Open Source",
                description: "Code audited and reviewed by the community. Open under MIT license",
                image: R.image.settings_icon()
            ),
        ])
        introView?.backgroundColor = .white
        introView?.pageControlY = 130
        introView?.pageControl.pageIndicatorTintColor = Colors.lightGray
        introView?.pageControl.currentPageIndicatorTintColor = Colors.black
        introView?.skipButton = button
        introView?.skipButtonY = 70
        introView?.swipeToExit = false
        introView?.skipButtonAlignment = .center
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 0.3)

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
        page.titleIconPositionY = 140
        page.descPositionY = 250
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
    
    @IBAction func start(_ sender: UIButton) {
        startFlow()
    }
}

extension WelcomeViewController: EAIntroDelegate {
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        
    }
    
    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        
    }
}
