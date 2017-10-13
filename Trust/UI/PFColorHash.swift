// Copyright SIX DAY LLC. All rights reserved.

import Foundation

open class PFColorHash {

    lazy var lightness: [Double] = [0.35, 0.5, 0.65]

    lazy var saturation: [Double] = [0.35, 0.5, 0.65]

    lazy var hash = { (_ str: String) -> Int64 in
        let seed1: Int64 = 131
        let seed2: Int64 = 137
        var ret: Int64 = 0
        let hashString = str + "x"
        var constantInt: Int64 = 9007199254740991   // pow(2, 53) - 1
        let maxSafeInt: Int64 = constantInt / seed2
        for element in hashString.characters {
            if ret > maxSafeInt {
                ret /= seed2
            }
            ret = ret * seed1 + element.unicodeScalarCodePoint()
        }
        return ret
    }

    // MARK: Init Methods
    init() {}

    init(lightness: [Double]) {
        self.lightness = lightness
    }

    init(saturation: [Double]) {
        self.saturation = saturation
    }

    init(lightness: [Double], saturation: [Double]) {
        self.lightness = lightness
        self.saturation = saturation
    }

    init(hash: @escaping (String) -> Int64) {
        self.hash = hash
    }

    // MARK: Public Methods
    final func hsl(_ str: String) -> (h: Double, s: Double, l: Double) {
        var hashValue: Int64 = hash(str)
        let h = hashValue % 359

        hashValue /= 360
        var count: Int64 = Int64(saturation.count)
        var index = Int(hashValue % count)
        let s = saturation[index]

        hashValue /= count
        count = Int64(lightness.count)
        index = Int(hashValue % count)
        let l = lightness[index]

        return (Double(h), Double(s), Double(l))
    }

    final func rgb(_ str: String) -> (r: Int, g: Int, b: Int) {
        let hslValue = hsl(str)
        return hsl2rgb(hslValue.h, s: hslValue.s, l: hslValue.l)
    }

    final func hex(_ str: String) -> String {
        let rgbValue = rgb(str)
        return rgb2hex(rgbValue.r, g: rgbValue.g, b: rgbValue.b)
    }

    // MARK: Private Methods
    fileprivate final func hsl2rgb(_ h: Double, s: Double, l: Double) -> (r: Int, g: Int, b: Int) {
        let hue = h / 360
        let q = l < 0.5 ? l * (1 + s) :l + s - l * s
        let p = 2 * l - q
        let array = [hue + 1/3, hue, hue - 1/3].map({ (color: Double) -> Int in
            var ret = color
            if ret < 0 {
                ret += 1
            }
            if ret > 1 {
                ret -= 1
            }
            if ret < 1 / 6 {
                ret = p + (q - p) * 6 * ret
            } else if ret < 0.5 {
                ret = q
            } else if ret < 2 / 3 {
                ret = p + (q - p) * 6 * (2 / 3 - ret)
            } else {
                ret = p
            }
            return Int(ret * 255)
            }
        )
        return (array[0], array[1], array[2])
    }

    fileprivate final func rgb2hex(_ r: Int, g: Int, b: Int) -> String {
        return String(format:"%X", r) + String(format:"%X", g) + String(format:"%X", b)
    }
}

// MARK: Character To ASCII
extension Character {
    func unicodeScalarCodePoint() -> Int {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars

        return Int(scalars[scalars.startIndex].value)
    }
}
