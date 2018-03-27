// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct DAppViewModel {

    let dapp: DAppModel

    var title: String {
        return dapp.name
    }

    var description: String {
        return dapp.description
    }

    var imageURL: URL? {
        return dapp.imageURL
    }

    var placeholderImage: UIImage? {
        return R.image.launch_screen_logo()
    }
}
