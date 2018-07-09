// Copyright DApps Platform Inc. All rights reserved.
import Foundation
import UIKit
import StoreKit

final class HelpUsCoordinator: Coordinator {

    let navigationController: NavigationController
    let appTracker: AppTracker
    var coordinators: [Coordinator] = []

    private let viewModel = HelpUsViewModel()
    private lazy var wellDoneController: WellDoneViewController = {
        let controller = WellDoneViewController()
        controller.navigationItem.title = viewModel.title
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()

    init(
        navigationController: NavigationController = NavigationController(),
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
            presentWellDone()
        default: break
        }
    }

    func rateUs() {
        if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() } else {
            let url = URL(string: "itms-apps://itunes.apple.com/app/id1288339409")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        appTracker.completedRating = true
    }

    private func presentWellDone() {
        navigationController.present(NavigationController(rootViewController: wellDoneController), animated: true, completion: nil)
    }

    @objc private func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func presentSharing(in controller: UIViewController, from sender: UIView) {
        controller.showShareActivity(from: sender, with: viewModel.activityItems)
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
