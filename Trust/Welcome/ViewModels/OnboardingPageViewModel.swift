// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct OnboardingPageViewModel {
    var title: String
    var subtitle: String
    var image: UIImage

    init() {
        title = ""
        subtitle = ""
        image = #imageLiteral(resourceName: "onboarding_lock")
    }

    init(title: String, subtitle: String, image: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
