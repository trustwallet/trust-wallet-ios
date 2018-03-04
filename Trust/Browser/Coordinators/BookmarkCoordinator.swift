// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BookmarksCoordinatorDelegate: class {
    func didCancel(in coordinator: BookmarksCoordinator)
    func didSelectBookmark(bookmark: BookmarkObject, in coordinator: BookmarksCoordinator)
    func didAddBookmark(bookmark: BookmarkObject, in coordinator: BookmarksCoordinator)
    func didDeleteBookmark(bookmark: BookmarkObject, in coordinator: BookmarksCoordinator)
}

class BookmarksCoordinator: Coordinator {
    let navigationController: UINavigationController
    let store: BookmarksStore
    var coordinators: [Coordinator] = []
    
    lazy var bookmarksViewController: BookmarkViewController = {
        let controller = BookmarkViewController(store: store)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        controller.allowsBookmarkDeletion = true
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
    
    @objc func add() {
        //Add
    }
}

extension BookmarksCoordinator: BookmarkViewControllerDelegate {
    func didSelectBookmark(bookmark: BookmarkObject, in viewController: BookmarkViewController) {
        delegate?.didSelectBookmark(bookmark: bookmark, in: self)
    }
    func didDeleteBookmark(bookmark: BookmarkObject, in viewController: BookmarkViewController) {
        delegate?.didDeleteBookmark(bookmark: bookmark, in: self)
    }
}
