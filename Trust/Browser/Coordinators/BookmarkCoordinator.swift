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
        let controller = BookmarkViewController(bookmarksStore: bookmarksStore)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()
    let bookmarksStore: BookmarksStore
    weak var delegate: BookmarksCoordinatorDelegate?

    init(
        navigationController: UINavigationController = NavigationController(),
        bookmarksStore: BookmarksStore
    ) {
        self.navigationController = navigationController
        self.bookmarksStore = bookmarksStore
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
