// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum PaymentFlow {
    case send
    case request
}

class SendAndRequestViewContainer: UIViewController {

    var flow: PaymentFlow {
        didSet {
            updateTo(flow: flow)
        }
    }
    let account: Account

    lazy var sendController: SendViewController = {
        return SendViewController(account: self.account)
    }()

    lazy var requestController: RequestViewController = {
        return RequestViewController(account: self.account)
    }()

    lazy var  segment: UISegmentedControl = {
        let segment =  UISegmentedControl(frame: .zero)
        segment.insertSegment(withTitle: "Send", at: 0, animated: false)
        segment.insertSegment(withTitle: "Request", at: 1, animated: false)
        segment.addTarget(self, action: #selector(segmentChange), for: .valueChanged)
        return segment
    }()

    init(flow: PaymentFlow, account: Account) {
        self.flow = flow
        self.account = account
        super.init(nibName: nil, bundle: nil)

        navigationItem.titleView = segment
        view.backgroundColor = .white

        updateTo(flow: flow)
    }

    func segmentChange() {
        flow = PaymentFlow(
            selectedSegmentIndex: segment.selectedSegmentIndex
        )
    }

    func updateTo(flow: PaymentFlow) {
        switch flow {
        case .send:
            add(asChildViewController: sendController)
            remove(asChildViewController: requestController)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Send",
                style: .done,
                target: sendController,
                action: #selector(SendViewController.send)
            )
        case .request:
            add(asChildViewController: requestController)
            remove(asChildViewController: sendController)
            navigationItem.rightBarButtonItem = nil
        }
        segment.selectedSegmentIndex = flow.selectedSegmentIndex
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PaymentFlow {
    init(selectedSegmentIndex: Int) {
        switch selectedSegmentIndex {
        case 0: self = .send
        case 1: self = .request
        default: self = .send
        }
    }

    var selectedSegmentIndex: Int {
        switch self {
        case .send: return 0
        case .request: return 1
        }
    }
}
