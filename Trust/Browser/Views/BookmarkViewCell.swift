// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class BookmarkViewCell: UITableViewCell {
    @IBOutlet weak var bookmarkTitleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var faviconImage: UIImageView!
    var viewModel: BookmarkViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            bookmarkTitleLabel.text = model.title
            urlLabel.text = model.url
        }
    }
}
