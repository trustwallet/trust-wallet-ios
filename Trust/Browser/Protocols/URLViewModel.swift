// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol URLViewModel {
    var urlText: String? { get }
    var title: String { get }
    var imageURL: URL? { get }
    var placeholderImage: UIImage? { get }
}

extension URLViewModel {
    var placeholderImage: UIImage? {
        return R.image.launch_screen_logo()
    }
}
