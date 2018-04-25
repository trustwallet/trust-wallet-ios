// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class HalfModalPresentationController: UIPresentationController {
    private let dimmingView = UIView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
    }
    override func presentationTransitionWillBegin() {
        guard let container = containerView else { return }
        setUpGestures()
        dimmingView.frame = container.bounds
        dimmingView.alpha = 0.0
        container.addSubview(dimmingView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
            self.dimmingView.removeFromSuperview()
        })
    }
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView  else { return CGRect.zero }
        return CGRect(x: 0.0, y: container.bounds.height / 3.8, width: container.bounds.width, height: container.bounds.height )
    }
    override func adaptivePresentationStyle(for traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        var style: UIModalPresentationStyle = .custom
        // Checks for iPad, since iPad is the only class of devices that has a regular size class for both
        // traitCollection.horizontalSizeClass & traitCollection.verticalSizeClass
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            style = .formSheet
        }
        return style
    }
    private func setUpGestures() {
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(dismissDimmingView))
        dimmingView.addGestureRecognizer(tapGestureReconizer)
    }
    @objc private func dismissDimmingView() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
