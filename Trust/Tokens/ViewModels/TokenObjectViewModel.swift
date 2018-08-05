// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

struct TokenObjectViewModel {

    let token: TokenObject

    var imageURL: URL? {
        return URL(string: imagePath)
    }

    var title: String {
        return token.name.isEmpty ? token.symbol : (token.name + " (" + token.symbol + ")")
    }

    var placeholder: UIImage? {
        switch token.type {
        case .coin:
            return R.image.ethereum_logo_256()
        case .ERC20:
            let imageCache = ImageCaching.shared
            let key = token.coin.tokenTitle
            guard let image = imageCache.getImage(for: key) else {
                return imageCache.setImage(
                    drawImagesAndText(title: token.coin.tokenTitle),
                    for: key
                )
            }
            return image
        }
    }

    func drawImagesAndText(title: String) -> UIImage {
        let size = 80
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { ctx in
            // 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center



            // 3
            let attrs = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .medium),
                NSAttributedStringKey.foregroundColor: UIColor(hex: "ABABAB"),
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
            ]

            // 4
            let string = title
            string.draw(with: CGRect(x: 0, y: 0, width: size, height: size), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

            // 5
            //let mouse = UIImage(named: "mouse")
            //mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        return img
    }

    private var imagePath: String {
        let formatter = ImageURLFormatter()
        switch token.type {
        case .coin:
            return formatter.image(for: token.coin)
        case .ERC20:
            return formatter.image(for: token.contract)
        }
    }
}

extension Coin {
    var tokenTitle: String {
        switch self {
        case .poa: return "POA\n20"
        default: return "ERC\n20"
        }
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
