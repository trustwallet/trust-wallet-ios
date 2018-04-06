// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BookmarksCoordinatorDelegate: class {
    func didCancel(in coordinator: BookmarkCoordinator)
    func didSelectURL(_ url: URL, in coordinator: BookmarkCoordinator)
}

class BookmarkCoordinator: Coordinator {
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []

    lazy var rootViewController: MasterBoookmarksViewController = {
        let controller = MasterBoookmarksViewController(
            bookmarksViewController: bookmarksViewController,
            historyViewController: historyViewController,
            type: type
        )
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        return controller
    }()

    lazy var bookmarksViewController: BookmarkViewController = {
        let controller = BookmarkViewController(bookmarksStore: bookmarksStore)
        controller.delegate = self
        return controller
    }()

    lazy var historyViewController: HistoryViewController = {
        let controller = HistoryViewController(store: historyStore)
        controller.delegate = self
        return controller
    }()

    let bookmarksStore: BookmarksStore
    let historyStore: HistoryStore
    let type: BookmarksViewType
    weak var delegate: BookmarksCoordinatorDelegate?

    init(
        navigationController: UINavigationController = NavigationController(),
        bookmarksStore: BookmarksStore,
        historyStore: HistoryStore,
        type: BookmarksViewType
    ) {
        self.navigationController = navigationController
        self.bookmarksStore = bookmarksStore
        self.historyStore = historyStore
        self.type = type
    }

    func start() {
        navigationController.pushViewController(rootViewController, animated: false)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension BookmarkCoordinator: BookmarkViewControllerDelegate {
    func didSelectBookmark(_ bookmark: Bookmark, in viewController: BookmarkViewController) {
        guard let url = bookmark.linkURL else {
             return
        }
        delegate?.didSelectURL(url, in: self)
    }
}

extension BookmarkCoordinator: HistoryViewControllerDelegate {
    func didSelect(history: History, in controller: HistoryViewController) {
        guard let url = history.URL else {
            return
        }
        delegate?.didSelectURL(url, in: self)
    }
}
