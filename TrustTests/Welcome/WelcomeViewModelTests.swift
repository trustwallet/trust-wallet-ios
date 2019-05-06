// Copyright DApps Platform Inc. All rights reserved.

import XCTest
@testable import IPOS

class WelcomeViewModelTests: XCTestCase {
    
    func testTitle() {
        let viewModel = WelcomeViewModel()
        
        XCTAssertEqual("Welcome", viewModel.title)
    }
}
