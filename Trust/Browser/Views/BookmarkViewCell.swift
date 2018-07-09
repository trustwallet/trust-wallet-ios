// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class BookmarkViewCell: UITableViewCell {

    @IBOutlet weak var bookmarkTitleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var faviconImage: UIImageView!
    var viewModel: URLViewModel? {
        didSet {
            guard let model = viewModel else {
                return
            }
            bookmarkTitleLabel.text = model.title
            urlLabel.text = model.urlText
            faviconImage?.kf.setImage(
                with: viewModel?.imageURL,
                placeholder: viewModel?.placeholderImage
            )
        }
    }
}
