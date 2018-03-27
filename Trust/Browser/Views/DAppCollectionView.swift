// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Kingfisher

protocol DAppCollectionViewDelegate: class {
    func didSelect(dapp: DAppModel, in view: DAppCollectionView)
}

class DAppCollectionView: UIView {

    lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    weak var delegate: DAppCollectionViewDelegate?

    private struct Layout {
        static let cellHeight: CGFloat = 78
        static let numberOfItems = 4
    }

    var elements: [DAppModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(R.nib.dAppViewCell)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func index(for indexPath: IndexPath) -> Int {
        return (indexPath.section * 2) + indexPath.row
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: Layout.cellHeight * CGFloat(numberOfSections(in: collectionView))
        )
    }
}

extension DAppCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(Layout.numberOfItems, 0)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return max(min(elements.count/Layout.numberOfItems, 1), 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.dAppViewCell.name, for: indexPath) as! DAppViewCell
        let index = self.index(for: indexPath)
        let dapp = elements[index]
        cell.nameLabel.text = dapp.name
        cell.dappImageView?.kf.setImage(
            with: dapp.imageURL,
            placeholder: .none
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = self.index(for: indexPath)
        let dapp = elements[index]
        delegate?.didSelect(dapp: dapp, in: self)
    }
}

extension DAppCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/CGFloat(Layout.numberOfItems), height: Layout.cellHeight)
    }
}
