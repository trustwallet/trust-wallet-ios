// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class TrustDocumentPickerViewController: UIDocumentPickerViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().tintColor = AppStyle.docPickerNavigationBarTintColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UINavigationBar.appearance().tintColor = AppStyle.navigationBarTintColor
    }
}
