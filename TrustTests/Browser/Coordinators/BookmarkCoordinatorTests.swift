// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class BookmarkCoordinatorTests: XCTestCase {
    
    func testStart() {
        let coordinator = BookmarkCoordinator(
            bookmarksStore: BookmarksStore(realm: .make())
        )

        coordinator.start()

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is BookmarkViewController)
    }
}
