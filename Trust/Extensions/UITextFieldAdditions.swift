// Copyright DApps Platform Inc. All rights reserved.

import UIKit

var key: Void?

class UITextFieldAdditions: NSObject {
    var isCopyPasteDisabled: Bool = false
}

extension UITextField {
    var isCopyPasteDisabled: Bool {
        get {
            return self.getAdditions().isCopyPasteDisabled
        } set {
            self.getAdditions().isCopyPasteDisabled = newValue
        }
    }
    private func getAdditions() -> UITextFieldAdditions {
        var additions = objc_getAssociatedObject(self, &key) as? UITextFieldAdditions
        if additions == nil {
            additions = UITextFieldAdditions()
            objc_setAssociatedObject(self, &key, additions!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return additions!
    }
    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if (action == #selector(UIResponderStandardEditActions.paste(_:)) || (action == #selector(UIResponderStandardEditActions.cut(_:)))) && self.isCopyPasteDisabled {
            return nil
        }
        return super.target(forAction: action, withSender: sender)
    }
}
