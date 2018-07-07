// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Eureka

struct AppFormAppearance {

    static func textArea(tag: String? = .none, callback: @escaping (TextAreaRow) -> Void) -> TextAreaRow {
        let textArea = TextAreaRow(tag) {
            $0.title = ""
        }.onRowValidationChanged {
            AppFormAppearance.onRowValidationChanged(baseCell: $0, row: $1)
        }
        callback(textArea)
        return textArea
    }

    static func textField(tag: String? = .none, callback: @escaping (TextRow) -> Void) -> TextRow {
        let textField = TextRow(tag) {
            $0.title = ""
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.textField?.textColor = .red
            }
        }.onRowValidationChanged {
            AppFormAppearance.onRowValidationChanged(baseCell: $0, row: $1)
        }
        callback(textField)
        return textField
    }

    static func textFieldFloat(tag: String? = .none, callback: @escaping (TextFloatLabelRow) -> Void) -> TextFloatLabelRow {
        let textField = TextFloatLabelRow(tag) {
            $0.title = ""
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.textField?.textColor = .red
            }
        }.onRowValidationChanged {
            AppFormAppearance.onRowValidationChanged(baseCell: $0, row: $1)
        }
        callback(textField)
        return textField
    }

    static func onRowValidationChanged(baseCell: BaseCell, row: BaseRow) {
        guard let rowIndex = row.indexPath?.row, let rowSection = row.section else { return }

        while rowSection.count > rowIndex + 1 && rowSection[rowIndex  + 1] is LabelRow {
            rowSection.remove(at: rowIndex + 1)
        }

        if !row.isValid {
            for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                let labelRow = LabelRow {
                    $0.title = validationMsg
                    $0.cell.height = { 36 }
                }.cellUpdate { cell, _ in
                    cell.textLabel?.font = AppStyle.error.font
                    cell.textLabel?.textColor = AppStyle.error.textColor
                }
                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
            }
        }
    }

    static func button(_ title: String? = .none, callback: @escaping (ButtonRow) -> Void) -> ButtonRow {
        let button = ButtonRow(title)
        .cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        }
        callback(button)
        return button
    }
}
