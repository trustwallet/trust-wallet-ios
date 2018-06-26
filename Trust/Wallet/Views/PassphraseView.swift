// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class PassphraseView: UIView {

    lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return layout
    }()
    lazy var collectionView: DynamicCollectionView = {
        let collectionView = DynamicCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    var words: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var isEditable: Bool = false
    var didDeleteItem: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(R.nib.wordCollectionViewCell)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PassphraseView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.wordCollectionViewCell.identifier, for: indexPath) as! WordCollectionViewCell
        cell.wordLabel.text = words[indexPath.row]
        return cell
    }
}

extension PassphraseView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard isEditable else { return }

        let item = words[indexPath.row]
        words.remove(at: indexPath.row)
        collectionView.reloadData()
        didDeleteItem?(item)
    }
}
