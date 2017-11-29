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
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
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

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            subtitleLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 240),
        ])
    }
}
