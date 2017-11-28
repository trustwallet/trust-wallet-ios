// Copyright SIX DAY LLC. All rights reserved.

import UIKit

final class OnboardingPage: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    var model = OnboardingPageViewModel() {
        didSet {
            imageView.image = model.image
            titleLabel.text = model.title
            subtitleLabel.text = model.subtitle
        }
    }

    static func create(model: OnboardingPageViewModel) -> OnboardingPage {
        let nib = R.nib.onboardingPage
        let view = nib.instantiate(withOwner: nil, options: nil).first as! OnboardingPage
        view.model = model
        return view
    }
}
