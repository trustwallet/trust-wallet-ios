// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class RequestCoordinator: RootCoordinator {
    let session: WalletSession
    var coordinators: [Coordinator] = []

    var rootViewController: UIViewController {
        return controller
    }

    private lazy var controller: UIViewController = {
        let controller = RequestViewController(viewModel: viewModel)
        controller.navigationItem.rightBarButtonItem = shareBarButtonitem
        controller.hidesBottomBarWhenPushed = true
        return controller
    }()
    lazy var shareBarButtonitem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
    }()
    private lazy var viewModel: RequestViewModel = {
        return RequestViewModel(coinTypeViewModel: coinTypeViewModel)
    }()
    private let coinTypeViewModel: CoinTypeViewModel

    init(
        session: WalletSession,
        coinTypeViewModel: CoinTypeViewModel
    ) {
        self.session = session
        self.coinTypeViewModel = coinTypeViewModel
    }

    @objc func share(_ sender: UIBarButtonItem) {
        let items = [viewModel.shareMyAddressText, (rootViewController as? RequestViewController)?.imageView.image as Any].compactMap { $0 }
        let activityViewController = UIActivityViewController.make(items: items)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
}
