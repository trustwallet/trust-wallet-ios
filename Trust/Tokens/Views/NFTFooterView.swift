// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class NFTFooterView: UIView {

    let label = UILabel()

    init() {
        super.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = NSLocalizedString("nft.poweredBy.label.text", value: "Powered by OpenSea", comment: "")
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = Colors.lightBlack
        addSubview(label)
        label.anchor(to: self, margin: 15)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
