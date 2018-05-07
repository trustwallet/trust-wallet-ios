// Copyright SIX DAY LLC. All rights reserved.

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
        guard let rowSection = row.section else { return }
        let footerView = rowSection.footer?.viewForSection(rowSection, type: .footer) as! FormFooterView
        if !row.isValid {
            for validationMsg in row.validationErrors.map({ $0.msg }) {
                footerView.errorLabel.text = validationMsg
                footerView.errorLabel.textColor = AppStyle.error.textColor
                footerView.errorLabel.font = AppStyle.error.font
                rowSection.reload()
            }
        } else {
            footerView.errorLabel.text = nil
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
