// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class PasscodeCharacterView: UIView {
    /**
     * YES if the view represents no character (to display a hyphen character). NO otherwise (to display a bullet character).
     */
    private var _isEmpty: Bool = false
    var isEmpty: Bool {
        get {
            return _isEmpty
        }
        set {
            if self.isEmpty != newValue {
                _isEmpty = newValue
                redraw()
            }
            _isEmpty = newValue
        }
    }
    /**
     * The fill color of the passcode character.
     */
    private var _fillColor: UIColor?
    var fillColor: UIColor? {
        get {
            return _fillColor
        }
        set {
            _fillColor = newValue
            guard let cgColor = _fillColor?.cgColor else {
                return
            }
            hyphen?.fillColor = cgColor
            hyphen?.strokeColor = cgColor
            circle?.fillColor = cgColor
            circle?.strokeColor = cgColor
        }
    }
    private var circle: CAShapeLayer?
    private var hyphen: CAShapeLayer?
    override func layoutSubviews() {
        commonInit()
    }
    func commonInit() {
        isEmpty = true
        backgroundColor = UIColor.clear
        drawCircle()
        drawHyphen()
        redraw()
    }
    func redraw() {
        circle?.isHidden = isEmpty
        hyphen?.isHidden = !isEmpty
    }
    func drawCircle() {
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
    func drawHyphen() {
        let horizontalMargin: CGFloat = 1
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
}
