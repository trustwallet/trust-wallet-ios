// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol RootViewControllerProvider: class {
    var providedRootController: UIViewController { get }
}
