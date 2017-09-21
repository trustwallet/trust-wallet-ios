// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit

class BalanceTitleView: UIView {

    /// UIAppearance compatible property
    dynamic var titleTextColor: UIColor {
        get { return self.label.backgroundColor! }
        set { self.label.textColor = newValue }
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
