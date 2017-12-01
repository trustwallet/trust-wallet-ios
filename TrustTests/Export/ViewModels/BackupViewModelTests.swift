// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class BackupViewModelTests: XCTestCase {
    
    func testHeadlineText() {
        let config: Config = .make(defaults: .test)
        let viewModel = BackupViewModel(config: config)

        XCTAssertEqual("No backup, no \(config.server.name).", viewModel.headlineText)
    }
}
