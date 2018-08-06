// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import UIKit

class TokenImageGenerator {
    static func drawImagesAndText(title: String) -> UIImage {
        let size: CGFloat = 70
        let labelFont: CGFloat = 18
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { _ in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: labelFont, weight: .medium),
                NSAttributedStringKey.foregroundColor: UIColor(hex: "ABABAB"),
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
            ]
            let y = size/2 - labelFont - 2
            let string = title
            string.draw(with: CGRect(x: 0, y: y, width: size, height: size), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return img
    }
}

class ImageCaching: NSObject {
    static let shared = ImageCaching()

    var images: [String: UIImage] = [:]

    func getImage(for key: String) -> UIImage? {
        return images[key]
    }

    func setImage(_ image: UIImage, for key: String) -> UIImage {
        images[key] = image
        return image
    }
}

extension Coin {
    var tokenTitle: String {
        switch self {
        case .ethereum: return "ERC\n20"
        case .poa: return "POA\n20"
        case .ethereumClassic: return "ETC\n20"
        case .gochain: return "GO\n20"
        case .callisto: return "CLO\n20"
        default: return "ERC\n20"
        }
    }
}

