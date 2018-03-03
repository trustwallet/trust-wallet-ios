// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class NonFungibleTokensViewController: UIViewController {
    init(
        ) {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.red
    }
}
