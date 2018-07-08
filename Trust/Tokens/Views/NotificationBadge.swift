// Copyright DApps Platform Inc. All rights reserved.

import UIKit

extension UIView {

    @objc public func badge(text badgeText: String?) {
        badge(text: badgeText, appearance: BadgeAppearance())
    }

    public func badge(text badgeText: String?, appearance: BadgeAppearance) {
        badge(text: badgeText, badgeEdgeInsets: nil, appearance: appearance)
    }

    public func badge(text badgeText: String?, badgeEdgeInsets: UIEdgeInsets?, appearance: BadgeAppearance) {

        var badgeLabel: BadgeLabel!
        var doesBadgeExist = false
        for view in self.subviews {
            if view.tag == 1 && view is BadgeLabel {
                badgeLabel = view as! BadgeLabel
            }
        }
        if badgeText == nil && badgeLabel != nil {

            if appearance.animate {
                UIView.animate(withDuration: appearance.duration, animations: {
                    badgeLabel.alpha = 0.0
                    badgeLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

                }, completion: { (_) in

                    badgeLabel.removeFromSuperview()
                })
            } else {
                badgeLabel.removeFromSuperview()
            }
            return
        } else if badgeText == nil && badgeLabel == nil {
            return
        }

        if badgeLabel == nil {
            badgeLabel = BadgeLabel()
            badgeLabel.tag = 1
        } else {
            doesBadgeExist = true
        }

        let oldWidth: CGFloat?
        if doesBadgeExist {
            oldWidth = badgeLabel.frame.width
        } else {
            oldWidth = nil
        }

        badgeLabel.text = badgeText
        badgeLabel.font = UIFont.systemFont(ofSize: appearance.textSize)

        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = appearance.textAlignment

        badgeLabel.layer.backgroundColor = appearance.backgroundColor.cgColor
        badgeLabel.textColor = appearance.textColor

        let badgeSize = badgeLabel.frame.size

        let height = max(18, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)

        badgeLabel.frame.size = CGSize(width: width, height: height)

        if doesBadgeExist {
            badgeLabel.removeFromSuperview()
        }
        self.addSubview(badgeLabel)

        let centerY = appearance.distanceFromCenterY == 0 ? -(bounds.size.height / 2) : appearance.distanceFromCenterY

        let centerX = appearance.distanceFromCenterX == 0 ? (bounds.size.width / 2) : appearance.distanceFromCenterX

        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(height)))

        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width)))

        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: centerX))

        self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: centerY))

        badgeLabel.layer.borderColor = appearance.borderColor.cgColor
        badgeLabel.layer.borderWidth = appearance.borderWidth

        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height / 2

        if appearance.allowShadow {
            badgeLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
            badgeLabel.layer.shadowRadius = 1
            badgeLabel.layer.shadowOpacity = 0.5
            badgeLabel.layer.shadowColor = UIColor.black.cgColor
        }

        if !doesBadgeExist {
            if appearance.animate {
                badgeLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                UIView.animate(withDuration: appearance.duration,
                               delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5,
                               options: [],
                               animations: {
                                badgeLabel.transform = .identity
                },
                               completion: nil)
            }
        } else {
            if appearance.animate, let oldWidth = oldWidth {
                let currentWidth = badgeLabel.frame.width
                badgeLabel.frame.size.width = oldWidth
                UIView.animate(withDuration: appearance.duration) {
                    badgeLabel.frame.size.width = currentWidth
                }
            }
        }
    }

}

@objc class BadgeLabel: UILabel {}

public struct BadgeAppearance {
    public var textSize: CGFloat
    public var textAlignment: NSTextAlignment
    public var borderColor: UIColor
    public var borderWidth: CGFloat
    public var allowShadow: Bool
    public var backgroundColor: UIColor
    public var textColor: UIColor
    public var animate: Bool
    public var duration: TimeInterval
    public var distanceFromCenterY: CGFloat
    public var distanceFromCenterX: CGFloat

    public init() {
        textSize = 12
        textAlignment = .center
        backgroundColor = UIColor(hex: "ff3a2f")
        textColor = .white
        animate = true
        duration = 0.2
        borderColor = .clear
        borderWidth = 0
        allowShadow = false
        distanceFromCenterY = 0
        distanceFromCenterX = 0
    }

}
