// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class PassphraseContentView: UIView {

    let passphraseView = PassphraseView()


    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
