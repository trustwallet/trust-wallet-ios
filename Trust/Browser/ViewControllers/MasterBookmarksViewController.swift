// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum BookmarksViewType: Int {
    case bookmarks
    case history
}

class MasterBoookmarksViewController: UIViewController {

    fileprivate lazy var segmentController: UISegmentedControl = {
        let items = [
            NSLocalizedString("Bookmarks", value: "Bookmarks", comment: ""),
            NSLocalizedString("History", value: "History", comment: ""),
        ]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let selectedTextAttributes = [NSAttributedStringKey.foregroundColor: Colors.blue]
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setDividerImage(UIImage.filled(with: UIColor.white), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        for selectView in segmentedControl.subviews {
            selectView.tintColor = UIColor.white
        }
        return segmentedControl
    }()

    var bookmarksViewController: BookmarkViewController
    var historyViewController: HistoryViewController

    init(
        bookmarksViewController: BookmarkViewController,
        historyViewController: HistoryViewController,
        type: BookmarksViewType
    ) {
        self.bookmarksViewController = bookmarksViewController
        self.historyViewController = historyViewController
        super.init(nibName: nil, bundle: nil)

        segmentController.selectedSegmentIndex = type.rawValue
        //updateView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = segmentController
        setupView()
    }

    private func setupView() {
        updateView()
    }

    private func updateView() {
        if segmentController.selectedSegmentIndex == BookmarksViewType.bookmarks.rawValue {
            remove(asChildViewController: historyViewController)
            add(asChildViewController: bookmarksViewController)
        } else {
            remove(asChildViewController: bookmarksViewController)
            add(asChildViewController: historyViewController)
        }
    }

    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }

    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }

    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
