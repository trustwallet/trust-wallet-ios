// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

extension UIImage {
    static func filled(with color: UIColor) -> UIImage {
        let pixelScale = UIScreen.main.scale
        let pixelSize = 1 / pixelScale
        let fillSize = CGSize(width: pixelSize, height: pixelSize)
        let fillRect = CGRect(origin: CGPoint.zero, size: fillSize)
        UIGraphicsBeginImageContextWithOptions(fillRect.size, false, pixelScale)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext!.setFillColor(color.cgColor)
        graphicsContext!.fill(fillRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 7, y: 7)
            if let output = filter.outputImage?.transformed(by: transform), let cgImage = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
