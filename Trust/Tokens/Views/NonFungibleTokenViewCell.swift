// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Kingfisher

final class NonFungibleTokenViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!

    fileprivate var viewModel: NonFungibleTokenCellViewModel?
    weak var delegate: NonFungibleTokensViewControllerDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(R.nib.nonFungibleCollectionViewCell(), forCellWithReuseIdentifier: R.nib.nonFungibleCollectionViewCell.name)
    }

    func configure(viewModel: NonFungibleTokenCellViewModel) {
        self.viewModel = viewModel
        collectionView.backgroundColor = self.viewModel?.collectionViewBacgroundColor
        collectionView.reloadData()
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = viewModel, let cell = collectionView.cellForItem(at: indexPath) as? NonFungibleCollectionViewCell, let color = cell.imageViewBackground.backgroundColor  else {
            return
        }
        let token = model.token(for: indexPath)
        delegate?.didPress(token: token, with: color)
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.nonFungibleCollectionViewCell.name, for: indexPath) as? NonFungibleCollectionViewCell, let model = viewModel else {
            return UICollectionViewCell()
        }
        cell.configure(with: model.collectionViewModel(for: indexPath))
        return cell
    }
}
