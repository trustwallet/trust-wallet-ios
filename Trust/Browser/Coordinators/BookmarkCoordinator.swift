// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BookmarksCoordinatorDelegate: class {
    func didCancel(in coordinator: BookmarksCoordinator)
    func didSelectBookmark(bookmark: Bookmark, in coordinator: BookmarksCoordinator)
}

class BookmarksCoordinator: Coordinator {
    let navigationController: UINavigationController
    let store: BookmarksStore
    var coordinators: [Coordinator] = []
    lazy var bookmarksViewController: BookmarkViewController = {
        let controller = BookmarkViewController(store: store)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()
    weak var delegate: BookmarksCoordinatorDelegate?
    init(
        navigationController: UINavigationController,
        store: BookmarksStore
    ) {
        self.navigationController = navigationController
        self.store = store
    }
    func start() {
        navigationController.pushViewController(bookmarksViewController, animated: false)
    }
    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension BookmarksCoordinator: BookmarkViewControllerDelegate {
    func didSelectBookmark(bookmark: Bookmark, in viewController: BookmarkViewController) {
        delegate?.didSelectBookmark(bookmark: bookmark, in: self)
    }
}
