// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!

    fileprivate var viewModel: NonFungibleTokenCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(R.nib.nonFungibleCollectionViewCell(), forCellWithReuseIdentifier: R.nib.nonFungibleCollectionViewCell.name)
        collectionView.backgroundColor = UIColor.clear
    }

    func configure(viewModel: NonFungibleTokenCellViewModel) {
        self.viewModel = viewModel
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.nonFungibleCollectionViewCell.name, for: indexPath) as! NonFungibleCollectionViewCell
        return cell
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDelegate {

}
