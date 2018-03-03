// Copyright SIX DAY LLC. All rights reserved.

import UIKit
enum DeteilsViewType: Int {
    case tokens
    case nonFungibleTokens
}
class MasterViewController: UIViewController {
    fileprivate lazy var segmentController: UISegmentedControl = {
        let items = [NSLocalizedString("Tokens", value: "Tokens", comment: ""), NSLocalizedString("Collectable", value: "Collectable", comment: "")]
        let segmentController = UISegmentedControl(items: items)
        segmentController.selectedSegmentIndex = DeteilsViewType.tokens.rawValue
        segmentController.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        return segmentController
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        updateView()
    }
    private func updateView() {
        if segmentController.selectedSegmentIndex == DeteilsViewType.tokens.rawValue {
            remove(asChildViewController: nonFungibleTokensViewController)
            add(asChildViewController: tokensViewController)
        } else {
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
}
