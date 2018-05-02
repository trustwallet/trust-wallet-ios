// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!

    fileprivate var viewModel: NonFungibleTokenCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(R.nib.nonFungibleCollectionViewCell(), forCellWithReuseIdentifier: R.nib.nonFungibleCollectionViewCell.name)
    }

    func configure(viewModel: NonFungibleTokenCellViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

extension NonFungibleTokenViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = viewModel else {
            return
        }

        let tokenDictionary: [String: NonFungibleTokenObject] = ["token": model.token(for: indexPath)]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowToken"), object: nil, userInfo: tokenDictionary)
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
