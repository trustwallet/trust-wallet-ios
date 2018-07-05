// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka

class TokenInfoViewController: FormViewController {

    let token: TokenObject

    init(token: TokenObject) {
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
