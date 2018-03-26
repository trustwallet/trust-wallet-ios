// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let tabBarButtonView = item.value(forKey: "view") as? UIView else { return }

        let animationDuration: TimeInterval = 0.4
        let propertyAnimator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 0.5) {
            tabBarButtonView.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
        }
        propertyAnimator.addAnimations({ tabBarButtonView.transform = .identity }, delayFactor: CGFloat(animationDuration))
        propertyAnimator.startAnimation()
    }
}
