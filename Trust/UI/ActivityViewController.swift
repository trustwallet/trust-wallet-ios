// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ActivityViewController: UIActivityViewController {

    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    static func makeShareController(url: Any) -> ActivityViewController {
        return ActivityViewController(activityItems: [url], applicationActivities: nil)
    }
}
