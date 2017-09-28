// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

protocol TransactionConfigurationViewControllerDelegate: class {
    func didUpdate(configuration: TransactionConfiguration, in viewController: TransactionConfigurationViewController)
}

class TransactionConfigurationViewController: FormViewController {

    struct Values {
        static let speed = "speed"
    }

    var speedRow: SegmentedRow<String>? {
        return form.rowBy(tag: Values.speed) as? SegmentedRow
    }

    weak var delegate: TransactionConfigurationViewControllerDelegate?

    let configuration: TransactionConfiguration

    init(configuration: TransactionConfiguration) {
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        title = "Configuration"

        form = Section { $0.hidden = true }
            +++ Section(
                header: "Transaction",
                footer: configuration.speed.timeTitle
            )
            <<< SegmentedRow<String>(Values.speed) {
                $0.title = "Processing speed"
                $0.options = [
                    TransactionSpeed.fast.title,
                    TransactionSpeed.regular.title,
                ]
                $0.value = configuration.speed.title
                $0.selectorTitle = configuration.speed.title
                $0.onChange { row in
                    let speed = TransactionSpeed(title: row.value ?? "")
                    row.section?.footer = HeaderFooterView(title: speed.timeTitle)
                    row.section?.reload(with: .none)
                }
            }
    }

    func done() {
        let speed = TransactionSpeed(title: speedRow?.value ?? "")

        let configuration = TransactionConfiguration(
            speed: speed
        )

        delegate?.didUpdate(configuration: configuration, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionSpeed {
    var title: String {
        switch self {
        case .fast: return "Fast"
        case .regular: return "Regular"
        case .custom: return "Custom"
        }
    }

    var timeTitle: String {
        switch self {
        case .fast: return "Estimated delivery: 1-2 minutes."
        case .regular: return "Estimated delivery: 2-5 minutes."
        case .custom: return "Custom"
        }
    }

    init(title: String) {
        switch title {
        case TransactionSpeed.fast.title: self = .fast
        case TransactionSpeed.regular.title: self = .regular
        default: self = .fast
        }
    }
}
