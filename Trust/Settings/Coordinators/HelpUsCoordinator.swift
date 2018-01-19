// Copyright SIX DAY LLC. All rights reserved.
import Foundation
import UIKit
import StoreKit

class HelpUsCoordinator: Coordinator {

    let navigationController: UINavigationController
    let appTracker: AppTracker
    var coordinators: [Coordinator] = []

    private let viewModel = HelpUsViewModel()
    init(
        navigationController: UINavigationController = NavigationController(),
        appTracker: AppTracker = AppTracker()
        ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.appTracker = appTracker
    }

    func start() {
        switch appTracker.launchCountForCurrentBuild {
        case 6 where !appTracker.completedRating:
            rateUs()
        case 12 where !appTracker.completedSharing:
            wellDone()
        default: break
        }
    }

    func rateUs() {
        if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() } else {
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1288339409")!)
        }
        appTracker.completedRating = true
    }

    private func wellDone() {
        let controller = WellDoneViewController()
        controller.navigationItem.title = viewModel.title
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        let nav = NavigationController(rootViewController: controller)
        navigationController.present(nav, animated: true, completion: nil)
    }

    @objc private func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func presentSharing(in viewController: UIViewController, from sender: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: viewModel.activityItems,
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = sender.centerRect
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

extension HelpUsCoordinator: WellDoneViewControllerDelegate {
    func didPress(action: WellDoneAction, sender: UIView, in viewController: WellDoneViewController) {
        switch action {
        case .other:
            presentSharing(in: viewController, from: sender)
        }

        appTracker.completedSharing = true
    }
}
