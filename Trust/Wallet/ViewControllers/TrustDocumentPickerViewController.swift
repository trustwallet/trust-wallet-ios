// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class TrustDocumentPickerViewController: UIDocumentPickerViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().tintColor = AppGlobalStyle.docPickerNavigationBarTintColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UINavigationBar.appearance().tintColor = AppGlobalStyle.navigationBarTintColor
    }
}
