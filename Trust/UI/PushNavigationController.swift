// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol RootViewControllerProvider: class {
    var rootViewController: UIViewController { get }
}

typealias RootCoordinator = Coordinator & RootViewControllerProvider

final class PushNavigationController: UIViewController {
    private let rootViewController: UIViewController
    private var viewControllersToChildCoordinators: [UIViewController: Coordinator] = [:]

    var viewControllers: [UIViewController] = [] {
        didSet {
            childNavigationController.viewControllers = viewControllers
        }
    }
    let childNavigationController: NavigationController

    init(rootViewController: UIViewController = UIViewController()) {
        self.rootViewController = rootViewController
        self.childNavigationController = NavigationController(rootViewController: rootViewController)
        super.init(nibName: nil, bundle: nil)
    }

    init(
        navigationBarClass: Swift.AnyClass?,
        toolbarClass: Swift.AnyClass?
    ) {
        self.rootViewController = UIViewController()
        self.childNavigationController = NavigationController(
            navigationBarClass: navigationBarClass,
            toolbarClass: toolbarClass
        )
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        childNavigationController.delegate = self
        childNavigationController.interactivePopGestureRecognizer?.delegate = self

        addChildViewController(childNavigationController)
        view.addSubview(childNavigationController.view)
        childNavigationController.didMove(toParentViewController: self)

        childNavigationController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            childNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childNavigationController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            childNavigationController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            childNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Public

    func pushCoordinator(coordinator: RootCoordinator, animated: Bool) {
        viewControllersToChildCoordinators[coordinator.rootViewController] = coordinator

        pushViewController(coordinator.rootViewController, animated: animated)
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        childNavigationController.pushViewController(viewController, animated: animated)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        childNavigationController.dismiss(animated: flag, completion: completion)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        childNavigationController.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return childNavigationController.preferredStatusBarStyle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PushNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Necessary to get the child navigation controller’s interactive pop gesture recognizer to work.
        return true
    }
}

// MARK: - UINavigationControllerDelegate

extension PushNavigationController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController,
                              didShowViewController viewController: UIViewController, animated: Bool) {
        cleanUpChildCoordinators()
    }

    private func cleanUpChildCoordinators() {
        for viewController in viewControllersToChildCoordinators.keys {
            if !childNavigationController.viewControllers.contains(viewController) {
                viewControllersToChildCoordinators.removeValue(forKey: viewController)
            }
        }
    }
}
