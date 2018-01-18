// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class PassphraseView: UIView {

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

    private struct Layout {
        static let cellHeight: CGFloat = 40
    }

    var words: [String] = [] {
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
        collectionView.register(R.nib.wordCollectionViewCell)

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

extension PassphraseView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.words.count / 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.wordCollectionViewCell.identifier, for: indexPath) as! WordCollectionViewCell
        let index = self.index(for: indexPath)
        cell.numberLabel.text = "\((index + 1))"
        cell.wordLabel.text = words[index]
        return cell
    }
}

extension PassphraseView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2, height: Layout.cellHeight)
    }
}
