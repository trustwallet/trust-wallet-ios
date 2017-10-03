// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class SendAndRequestViewControllerTests: XCTestCase {
    
    func testSendFlow() {
        let controller = SendAndRequestViewContainer(flow: .send, account: .make())

        XCTAssertEqual(0, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }

    func testRequestFlow() {
        let controller = SendAndRequestViewContainer(flow: .request, account: .make())

        XCTAssertEqual(1, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is RequestViewController)
    }

    func testUpdateFlowFromSendToRequest() {
        let controller = SendAndRequestViewContainer(flow: .send, account: .make())

        controller.updateTo(flow: .request)

        XCTAssertEqual(1, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is RequestViewController)
    }

    func testUpdateFlowFromRequestToSend() {
        let controller = SendAndRequestViewContainer(flow: .request, account: .make())

        controller.updateTo(flow: .send)

        XCTAssertEqual(0, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }
}
