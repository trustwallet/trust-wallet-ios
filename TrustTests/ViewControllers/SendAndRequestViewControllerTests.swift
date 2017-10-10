// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class SendAndRequestViewControllerTests: XCTestCase {
    
    func testSendFlow() {
        let controller = SendAndRequestViewContainer(flow: .send(destination: .none), account: .make())

        XCTAssertEqual(0, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }

    func testSendFlowDestination() {
        let address: Address = .make()
        let controller = SendAndRequestViewContainer(flow: .send(destination: address), account: .make())

        XCTAssertEqual(address.address, controller.sendController.addressRow?.value)
        XCTAssertEqual(0, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }

    func testRequestFlow() {
        let controller = SendAndRequestViewContainer(flow: .request, account: .make())

        XCTAssertEqual(1, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is RequestViewController)
    }

    func testUpdateFlowFromSendToRequest() {
        let controller = SendAndRequestViewContainer(flow: .send(destination: .none), account: .make())

        controller.updateTo(flow: .request)

        XCTAssertEqual(1, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is RequestViewController)
    }

    func testUpdateFlowFromRequestToSend() {
        let controller = SendAndRequestViewContainer(flow: .request, account: .make())

        controller.updateTo(flow: .send(destination: .none))

        XCTAssertEqual(0, controller.segment.selectedSegmentIndex)
        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }
}
