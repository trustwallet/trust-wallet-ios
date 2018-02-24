// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct NewTokenViewModel {
    let isEditing: Bool
    init(isEditing: Bool = false) {
        self.isEditing = isEditing
    }
    var title: String {
        if isEditing {
            return NSLocalizedString("tokens.token.edit.navigation.title", value: "Edit Custom Token", comment: "")
        } else {
            return NSLocalizedString("tokens.newtoken.navigation.title", value: "Add Custom Token", comment: "")
        }
    }
}
