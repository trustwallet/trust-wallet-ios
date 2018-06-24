// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UITableView {
    func lastIndexpath() -> IndexPath {
        let section = self.numberOfSections > 0 ? self.numberOfSections - 1 : 0
        let row = self.numberOfRows(inSection: section) > 0 ? self.numberOfRows(inSection: section) - 1 : 0
        return IndexPath(row: row, section: section)
    }
}
