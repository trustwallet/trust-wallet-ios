// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class BalanceTitleView: UIView {

    /// UIAppearance compatible property
    dynamic var titleColor: UIColor {
        get { return self.label.textColor! }
        set { self.label.textColor = newValue }
    }

    dynamic var titleFont: UIFont {
        get { return self.label.font! }
        set { self.label.font = newValue }
    }

    let label: UILabel = UILabel()

    var title: String = "" {
        didSet {
            label.text = title
            label.sizeToFit()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
