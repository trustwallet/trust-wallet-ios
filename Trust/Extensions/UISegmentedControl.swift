// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

extension UISegmentedControl {

    static func defaultSegmentedControl(items: [String]) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = DetailsViewType.tokens.rawValue
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let selectedTextAttributes = [NSAttributedStringKey.foregroundColor: Colors.blue]
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setDividerImage(UIImage.filled(with: UIColor.white), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        for selectView in segmentedControl.subviews {
            selectView.tintColor = UIColor.white
        }
        return segmentedControl
    }
}
