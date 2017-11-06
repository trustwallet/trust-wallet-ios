/*
	————————————————————————————————————————————————————————————————————————————
	SMP String Module.swift
	————————————————————————————————————————————————————————————————————————————
	Created by Marcel Kröker on 27.09.16.
	Copyright (c) 2016 Blubyte. All rights reserved.
*/

import Foundation

private func convert(number: String, fromBase: Int, toBase: Int) -> String
{
	let chars = [
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b",
		"c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
		"o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
		"M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
		"Y", "Z"
	]

	var res = ""
	var number = number

	if number[0] == "-"
	{
		res = "-"
		number = number[1..<number.count]
	}

	var sum = BInt(0)
	var multiplier = BInt(1)

	for char in number.characters.reversed()
	{
		if let digit = chars.index(of: String(char))
		{
			precondition(digit < fromBase)

			sum += digit * multiplier
			multiplier *= fromBase
		}
		else
		{
			fatalError()
		}
	}

	repeat
	{
		res = chars[(sum % toBase).toInt()!].appending(res)
		sum /= BInt(toBase)
	}
	while sum != 0

	return res
}


extension BInt: CustomStringConvertible
{
	// Required to conform to CustomStringConvertible.
	public var description: String
	{
		return (self.sign ? "-" : "").appending(limbsToString(self.limbs))
	}

	public init(number: String, withBase base: Int)
	{
		self.init(convert(number: number, fromBase: base, toBase: 10))
	}

	public func asString(withBase base: Int) -> String
	{
		return convert(number: self.description, fromBase: 10, toBase: base)
	}
}

extension BDouble: CustomStringConvertible
{
	public var description: String
	{
		var res = (self.sign ? "-" : "")

		res.append(limbsToString(self.numerator))

		if self.denominator != [1]
		{
			res.append("/".appending(limbsToString(self.denominator)))
		}

		return res
	}
}

//
////
//////
//MARK: - String conversion helper functions
//////
////
//

let DigitBase:     Digit = 1_000_000_000_000_000_000
let DigitHalfBase: Digit =             1_000_000_000
let DigitZeros           =                        18

/// Take a limb array and convert it into a string in base 10 representation.
private func limbsToString(_ limbs: Limbs) -> String
{
	// First, convert limbs to digits

	var digits: Digits = [0]
	var power: Digits = [1]

	for limb in limbs
	{
		let digit = (limb >= DigitBase)
			? [limb % DigitBase, limb / DigitBase]
			: [limb]

		mulDigits(addInto: &digits, digit, power)
		power = mulDigits(power, [446_744_073_709_551_616, 18])
	}

	// Then, convert digits to string
	return digitsToString(digits)
}

private func digitsToString(_ digits: Digits) -> String
{
	var res = String(digits.last!)

	if digits.count == 1 { return res }

	var i = digits.count - 2
	while i >= 0
	{
		var str = String(digits[i])

		var paddingZeros = String(
			repeating: "0",
			count: DigitZeros - str.count
		)

		paddingZeros.append(str)
		res.append(paddingZeros)

		i -= 1
	}

	return res
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
/********\
/*********\
/**********\
//MARK:    - Digit operations
\**********/
\*********/
\********/
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

private func addOneDigitToDigits(_ lhs: inout Digits, _ rhs: Digit, rhsPaddingZeroLimbs pz: Int)
{
	let lhc = lhs.count
	if pz >= lhc
	{
		if pz != lhc
		{
			lhs.append(contentsOf: Digits(repeating: 0, count: pz &- lhc))
		}
		lhs.append(rhs)
		return
	}

	// i < lhc
	var i = pz

	var newDigit = lhs[i] &+ rhs
	let ovfl = newDigit >= DigitBase
	if ovfl { newDigit -= DigitBase }

	lhs[i] = newDigit

	while ovfl
	{
		i += 1

		if i < lhc
		{
			lhs[i] += 1
			if lhs[i] != DigitBase { return }
			lhs[i] = 0

		}
		else
		{
			lhs.append(1)
			return
		}
	}
}

private func addTwoDigitsToDigits(_ lhs: inout Digits, _ rhsLo: Digit, _ rhsHi: Digit, rhsPaddingZeroLimbs pz: Int)
{
	let lhc = lhs.count
	if pz >= lhc
	{
		if pz != lhc
		{
			lhs.append(contentsOf: Digits(repeating: 0, count: pz &- lhc))
		}
		lhs.append(contentsOf: [rhsLo, rhsHi])
		return
	}

	// i < lhc
	var i = pz

	var newDigit = lhs[i] &+ rhsLo
	var ovfl = newDigit >= DigitBase
	if ovfl { newDigit -= DigitBase }

	lhs[i] = newDigit

	i += 1

	if i < lhc
	{
		if ovfl
		{
			newDigit = lhs[i] &+ rhsHi &+ 1
			ovfl = newDigit >= DigitBase
			if ovfl { newDigit -= DigitBase }
		}
		else
		{
			newDigit = lhs[i] &+ rhsHi
			ovfl = newDigit >= DigitBase
			if ovfl { newDigit -= DigitBase }
		}

		lhs[i] = newDigit
	}
	else
	{
		if ovfl
		{
			newDigit = rhsHi &+ 1
			if newDigit == DigitBase { newDigit = 0 }

			lhs.append(newDigit)

			if newDigit == 0 { lhs.append(1) }
		}
		else
		{
			lhs.append(rhsHi)
		}

		return
	}

	while ovfl
	{
		i += 1

		if i < lhc
		{
			lhs[i] += 1
			if lhs[i] != DigitBase { return }
			lhs[i] = 0

		}
		else
		{
			lhs.append(1)
			return
		}
	}
}

private func mulDigits(addInto res: inout Digits, _ lhs: Digits, _ rhs: Digits)
{
	res.reserveCapacity(lhs.count + rhs.count)

	var overflow: Bool
	var mulLo, lLo, lHi, rLo, rHi,
	resLo, resHi, K, l, r: Digit

	for i in 0..<lhs.count
	{
		l = lhs[i]
		if l == 0 { continue }

		for j in 0..<rhs.count
		{
			r = rhs[j]
			if r == 0 { continue }

			(mulLo, overflow) = Digit.multiplyWithOverflow(l, r)

			if overflow
			{
				/*
				From here, lhs * rhs >= 2^64, so res.count must be equal
				to 2
				*/

				(lLo, lHi) = (l % DigitHalfBase, l / DigitHalfBase)
				(rLo, rHi) = (r % DigitHalfBase, r / DigitHalfBase)

				K = (lHi * rLo) + (rHi * lLo)

				resLo = (lLo * rLo) + ((K % DigitHalfBase) * DigitHalfBase)
				resHi = (lHi * rHi) + (K / DigitHalfBase)

				if resLo >= DigitBase
				{
					resLo -= DigitBase
					resHi += 1
				}

				addTwoDigitsToDigits(&res, resLo, resHi, rhsPaddingZeroLimbs: i + j)
			}
			else
			{
				if mulLo < DigitBase
				{
					addOneDigitToDigits(&res, mulLo, rhsPaddingZeroLimbs: i + j)
				}
				else
				{
					addTwoDigitsToDigits(&res, mulLo % DigitBase, mulLo / DigitBase, rhsPaddingZeroLimbs: i + j)
				}
			}
		}
	}
}

private func mulDigits(_ lhs: Digits, _ rhs: Digits) -> Digits
{
	var res: Digits = [0]
	mulDigits(addInto: &res, lhs, rhs)
	return res
}
