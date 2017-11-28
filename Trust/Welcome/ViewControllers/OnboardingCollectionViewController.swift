// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class OnboardingCollectionViewController: UICollectionViewController {
    var pages = [OnboardingPageViewModel]()
    weak var pageControl: UIPageControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(R.nib.onboardingPage(), forCellWithReuseIdentifier: R.reuseIdentifier.page.identifier)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = view.bounds.size
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.page.identifier, for: indexPath) as! OnboardingPage
        cell.model = pages[indexPath.row]
        return cell
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        pageControl?.currentPage = Int(round(scrollView.contentOffset.x / flowLayout.itemSize.width - 0.5))
    }
}
