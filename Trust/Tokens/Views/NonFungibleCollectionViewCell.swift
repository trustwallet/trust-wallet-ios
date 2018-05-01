// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class NonFungibleCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet private weak var imageViewBackground: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    func config(with viewModel) {
        imageViewBackground.backgroundColor = UIColor.random()
    }
}
