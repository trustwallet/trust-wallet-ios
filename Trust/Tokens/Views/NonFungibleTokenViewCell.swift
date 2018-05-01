// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {

    fileprivate var viewModel: NonFungibleTokenCellViewModel?

    func configure(viewModel: NonFungibleTokenCellViewModel) {
        self.viewModel = viewModel
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDelegate {

}
