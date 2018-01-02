// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StoreKit

class HelpUsCoordinator {

    let navigationController: UINavigationController
    let appTracker: AppTracker

    init(
        navigationController: UINavigationController,
        appTracker: AppTracker
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.appTracker = appTracker
    }

    func start() {
        switch appTracker.launchCountForCurrentBuild {
        case 5, 8:
            rateUs()
        default: break
        }
    }

    private func rateUs() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
