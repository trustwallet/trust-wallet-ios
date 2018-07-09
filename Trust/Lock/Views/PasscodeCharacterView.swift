// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class PasscodeCharacterView: UIView {
    var isEmpty = true
    private var circle: CAShapeLayer?
    private var hyphen: CAShapeLayer?
    override func layoutSubviews() {
        commonInit()
    }
    private func commonInit() {
        isEmpty = true
        backgroundColor = UIColor.clear
        drawCircle()
        drawHyphen()
        redraw()
    }
    private func redraw() {
        circle?.isHidden = isEmpty
        hyphen?.isHidden = !isEmpty
    }
    private func drawCircle() {
        let borderWidth: CGFloat = 2
        let radius: CGFloat = bounds.width / 2 - borderWidth
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: CGRect(x: borderWidth, y: borderWidth, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).cgPath
        let circleColor: UIColor? = UIColor.black
        circle.fillColor = circleColor?.cgColor
        circle.strokeColor = circleColor?.cgColor
        circle.borderWidth = borderWidth
        layer.addSublayer(circle)
        self.circle = circle
    }
    private func drawHyphen() {
        let horizontalMargin: CGFloat = 2
        let hyphenHeight: CGFloat = bounds.height / 7
        let hyphen = CAShapeLayer()
        let hyphenPath = UIBezierPath()
        let leftTopCorner = CGPoint(x: horizontalMargin, y: 3 * hyphenHeight)
        let rightTopCorner = CGPoint(x: bounds.width - horizontalMargin, y: 3 * hyphenHeight)
        let rightBottomCorner = CGPoint(x: bounds.width - horizontalMargin, y: 4 * hyphenHeight)
        let leftBottomCorner = CGPoint(x: horizontalMargin, y: 4 * hyphenHeight)
        hyphenPath.move(to: leftTopCorner)
        hyphenPath.addLine(to: rightTopCorner)
        hyphenPath.addLine(to: rightBottomCorner)
        hyphenPath.addLine(to: leftBottomCorner)
        hyphen.path = hyphenPath.cgPath
        let hyphenColor: UIColor? = UIColor.black
        hyphen.fillColor = hyphenColor?.cgColor
        hyphen.strokeColor = hyphenColor?.cgColor
        layer.addSublayer(hyphen)
        self.hyphen = hyphen
    }
    func setEmpty(_ isEmpty: Bool) {
        if self.isEmpty != isEmpty {
            self.isEmpty = isEmpty
            redraw()
        }
    }
}
