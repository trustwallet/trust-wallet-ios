// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BulletinBoard

open class PageItem: BulletinItem {

    public init(title: String) {
        self.title = title
    }

    public let title: String
    public var image: UIImage?
    public var imageAccessibilityLabel: String?
    public var descriptionText: String?
    public var actionButtonTitle: String?
    public var alternativeButtonTitle: String?
    public weak var manager: BulletinManager?
    public var isDismissable: Bool = true
    public var nextItem: BulletinItem?
    public let interfaceFactory = BulletinInterfaceFactory()
    public var shouldCompactDescriptionText: Bool = false
    fileprivate var actionButton: ContainerView<HighlightButton>?
    fileprivate var alternativeButton: UIButton?
    public var actionHandler: ((PageItem) -> Void)?
    public var alternativeHandler: ((PageItem) -> Void)?

    @objc open func actionButtonTapped(sender: UIButton) {
        actionHandler?(self)
    }

    @objc open func alternativeButtonTapped(sender: UIButton) {
        alternativeHandler?(self)
    }

    public func makeArrangedSubviews() -> [UIView] {

        var arrangedSubviews = [UIView]()

        let titleLabel = interfaceFactory.makeTitleLabel()
        titleLabel.text = title
        arrangedSubviews.append(titleLabel)

        if let image = self.image {

            let imageView = UIImageView()
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 128).isActive = true

            if let imageAccessibilityLabel = imageAccessibilityLabel {
                imageView.isAccessibilityElement = true
                imageView.accessibilityLabel = imageAccessibilityLabel
            }

            arrangedSubviews.append(imageView)

        }

        if let descriptionText = self.descriptionText {

            let descriptionLabel = interfaceFactory.makeDescriptionLabel(isCompact: shouldCompactDescriptionText)
            descriptionLabel.text = descriptionText
            arrangedSubviews.append(descriptionLabel)
        }

        let buttonsStack = interfaceFactory.makeGroupStack()

        if let actionButtonTitle = self.actionButtonTitle {

            let actionButton = interfaceFactory.makeActionButton(title: actionButtonTitle)
            buttonsStack.addArrangedSubview(actionButton)
            actionButton.contentView.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)

            self.actionButton = actionButton
        }

        if let alternativeButtonTitle = self.alternativeButtonTitle {

            let alternativeButton = interfaceFactory.makeAlternativeButton(title: alternativeButtonTitle)
            buttonsStack.addArrangedSubview(alternativeButton)
            alternativeButton.addTarget(self, action: #selector(alternativeButtonTapped(sender:)), for: .touchUpInside)

            self.alternativeButton = alternativeButton
        }

        arrangedSubviews.append(buttonsStack)
        return arrangedSubviews

    }

    public func tearDown() {
        actionButton?.contentView.removeTarget(self, action: nil, for: .touchUpInside)
        alternativeButton?.removeTarget(self, action: nil, for: .touchUpInside)
        actionButton = nil
        alternativeButton = nil
    }

}
