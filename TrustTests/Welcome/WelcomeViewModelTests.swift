// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class WelcomeViewModelTests: XCTestCase {
    
    func testTitle() {
        let viewModel = WelcomeViewModel()
        
        XCTAssertEqual("Welcome", viewModel.title)
    }
}
