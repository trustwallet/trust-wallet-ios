// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ActivityViewController: UIActivityViewController {

    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    static func makeShareController(url: Any) -> ActivityViewController {
        return ActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().titleTextAttributes = nil // This makes the text black for messages and mail
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.white,
        ]
    }
}
