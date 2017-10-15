// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class SendAndRequestViewControllerTests: XCTestCase {
    
    func testSendFlow() {
        let controller = SendAndRequestViewContainer(flow: .send(destination: .none), session: .make())

        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }

    func testSendFlowDestination() {
        let address: Address = .make()
        let controller = SendAndRequestViewContainer(flow: .send(destination: address), session: .make())

        XCTAssertEqual(address.address, controller.sendController.addressRow?.value)
        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }

    func testRequestFlow() {
        let controller = SendAndRequestViewContainer(flow: .request, session: .make())

        XCTAssertTrue(controller.childViewControllers[0] is RequestViewController)
    }

    func testUpdateFlowFromSendToRequest() {
        let controller = SendAndRequestViewContainer(flow: .send(destination: .none), session: .make())

        controller.updateTo(flow: .request)

        XCTAssertTrue(controller.childViewControllers[0] is RequestViewController)
    }

    func testUpdateFlowFromRequestToSend() {
        let controller = SendAndRequestViewContainer(flow: .request, session: .make())

        controller.updateTo(flow: .send(destination: .none))

        XCTAssertTrue(controller.childViewControllers[0] is SendViewController)
    }
}
