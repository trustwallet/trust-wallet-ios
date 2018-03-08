// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class BookmarkViewCell: UITableViewCell {
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var URLLabel: UILabel!
    @IBOutlet weak var FaviconImage: UIImageView!
    var viewModel: BookmarkViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            TitleLabel.text = model.title
            URLLabel.text = model.url
        }
    }
}
