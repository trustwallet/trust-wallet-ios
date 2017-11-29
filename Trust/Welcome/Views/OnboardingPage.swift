// Copyright SIX DAY LLC. All rights reserved.

import UIKit

final class OnboardingPage: UICollectionViewCell {
    static let identifier = "Page"
    let style = OnboardingPageStyle()

    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!

    override var reuseIdentifier: String? {
        return OnboardingPage.identifier
    }

    var model = OnboardingPageViewModel() {
        didSet {
            imageView.image = model.image
            titleLabel.text = model.title
            subtitleLabel.text = model.subtitle
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        let topSpacingGuide = UILayoutGuide()
        addLayoutGuide(topSpacingGuide)

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        addSubview(imageView)

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
        addSubview(titleLabel)

        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = style.subtitleColor
        subtitleLabel.numberOfLines = 2
        subtitleLabel.font = style.subtitleFont
        addSubview(subtitleLabel)

        let bottomSpacingGuide = UILayoutGuide()
        addLayoutGuide(bottomSpacingGuide)

        NSLayoutConstraint.activate([
            topSpacingGuide.topAnchor.constraint(equalTo: topAnchor),
            topSpacingGuide.bottomAnchor.constraint(equalTo: imageView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomSpacingGuide.topAnchor),
            bottomSpacingGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            topSpacingGuide.heightAnchor.constraint(equalTo: bottomSpacingGuide.heightAnchor),
        ])
    }
}
