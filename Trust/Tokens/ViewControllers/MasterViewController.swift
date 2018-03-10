// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum DeteilsViewType: Int {
    case tokens
    case nonFungibleTokens
}

class MasterViewController: UIViewController {
    fileprivate lazy var segmentController: UISegmentedControl = {
        let items = [
            NSLocalizedString("Tokens", value: "Tokens", comment: ""),
            NSLocalizedString("Collectibles", value: "Collectibles", comment: "")
        ]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = DeteilsViewType.tokens.rawValue
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

    var tokensViewController: TokensViewController

    var nonFungibleTokensViewController: NonFungibleTokensViewController

    init(
        tokensViewController: TokensViewController,
        nonFungibleTokensViewController: NonFungibleTokensViewController
    ) {
        self.tokensViewController = tokensViewController
        self.nonFungibleTokensViewController = nonFungibleTokensViewController
        super.init(nibName: nil, bundle: nil)
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
        if segmentController.selectedSegmentIndex == DeteilsViewType.tokens.rawValue {
            showBarButtonItems()
            remove(asChildViewController: nonFungibleTokensViewController)
            add(asChildViewController: tokensViewController)
        } else {
            hideBarButtonItems()
            remove(asChildViewController: tokensViewController)
            add(asChildViewController: nonFungibleTokensViewController)
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

    private func showBarButtonItems() {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }

    private func hideBarButtonItems() {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
