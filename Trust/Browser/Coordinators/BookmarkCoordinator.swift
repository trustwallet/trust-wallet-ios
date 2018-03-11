// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BookmarksCoordinatorDelegate: class {
    func didCancel(in coordinator: BookmarkCoordinator)
    func didSelectBookmark(_ bookmark: Bookmark, in coordinator: BookmarkCoordinator)
}

class BookmarkCoordinator: Coordinator {
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    lazy var bookmarksViewController: BookmarkViewController = {
        let controller = BookmarkViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()
    weak var delegate: BookmarksCoordinatorDelegate?
    init(
        navigationController: UINavigationController = NavigationController(),
    ) {
        self.navigationController = navigationController
    }
    func start() {
        navigationController.pushViewController(bookmarksViewController, animated: false)
    }
    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension BookmarkCoordinator: BookmarkViewControllerDelegate {
    func didSelectBookmark(_ bookmark: Bookmark, in viewController: BookmarkViewController) {
        delegate?.didSelectBookmark(bookmark, in: self)
    }
}
