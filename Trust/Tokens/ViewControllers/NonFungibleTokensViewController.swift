// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class NonFungibleTokensViewController: UIViewController {
    fileprivate var viewModel: NonFungibleTokenViewModel
    init(viewModel: NonFungibleTokenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.red
    }
}
