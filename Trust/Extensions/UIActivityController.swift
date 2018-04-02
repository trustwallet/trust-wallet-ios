// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UIActivityViewController {
    func setActivityCompletion(completion: @escaping (() -> Void)) {
        self.completionWithItemsHandler = { _, completed, _, _ in
            if completed || !completed {
                // Set the tint globally via appearance proxy
                UINavigationBar.appearance().barTintColor = Colors.darkBlue
                UINavigationBar.appearance().titleTextAttributes = [
                    .foregroundColor: UIColor.white,
                ]
                completion() // Used to manually set the navBar tint/text back look at this for more info on why https://stackoverflow.com/a/21653004
            }
        }
    }
    open override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().barTintColor = nil // This fixes the issue with notes
        UINavigationBar.appearance().titleTextAttributes = nil // This makes the text black for messages and mail
    }
}
