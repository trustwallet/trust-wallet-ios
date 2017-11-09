/*
	————————————————————————————————————————————————————————————————————————————
	SMP Core.swift
	————————————————————————————————————————————————————————————————————————————
	Created by Marcel Kröker on 30.09.16.
	Copyright (c) 2016 Blubyte. All rights reserved.

	———— v1.0 ——————————————————————————————————————————————————————————————————
	- Initial Release.

	———— v1.1 ——————————————————————————————————————————————————————————————————
	- Improved String conversion, now about 45x faster, uses base 10^9 instead
	of base 10.
	- bytes renamed to limbs.
	- Uses typealias for limbs and digits.

	———— v1.2 ——————————————————————————————————————————————————————————————————
	- Improved String conversion, now about 10x faster, switched from base 10^9
	to 10^18 (biggest possible decimal base).
	- Implemented karatsuba multiplication algorithm, about 5x faster than the
	previous algorithm.
	- Addition is 1.3x faster.
	- Addtiton and subtraction omit trailing zeros, algorithms need less
	operations now.
	- Implemented exponentiation by squaring.
	- New storage (BStorage) for often used results.
	- Uses uint_fast64_t instead of UInt64 for Limbs and Digits.

	———— v1.3 ——————————————————————————————————————————————————————————————————
	- Huge Perfomance increase by skipping padding zeros and new multiplication
	algotithms.
	- Printing is now about 10x faster, now on par with GMP.
	- Some operations now use multiple cores.

	———— v1.4 ——————————————————————————————————————————————————————————————————
	- Reduced copying by using more pointers.
	- Multiplication is about 50% faster.
	- String to BInt conversion is 2x faster.
	- BInt to String also performs 50% better.

	———— v1.5 ——————————————————————————————————————————————————————————————————
	- Updated for full Swift 3 compatibility.
	- Various optimizations:
	- Multiplication is about 2x faster.
	- BInt to String conversion is more than 3x faster.
	- String to BInt conversion is more than 2x faster.

	———— v1.6 ——————————————————————————————————————————————————————————————————
	- Code refactored into modules.
	- Renamed the project to SMP (Swift Multiple Precision)
	- Added arbitrary base conversion.

	———— Evolution —————————————————————————————————————————————————————————————
	Planned features of BInt v2.0:
	- Switch between base for calculations:
	- Base 2^64 for fast calculations,
	- Base 10^18 for fast printing.
	- Implement efficient modulo arithmetric.
	- Implement Karatsuba on a higher level for even faster multiplications.
	- Implement some basic cryptography functions.
	- General code cleanup, better documentation.
	- More extensive tests.



	————————————————————————————————————————————————————————————————————————————
	Basic Project syntax conventions
	————————————————————————————————————————————————————————————————————————————

	———— Naming conventions ————————————————————————————————————————————————————
	Parameters, variables, constants, functions, methods: lowerCamelCase
	Classes, structs                                    : UpperCamelCase

	———— Formatting ————————————————————————————————————————————————————————————
	Indentation: Tabs
	Align: Spaces

	Style: allman
	func foo(...)
	{
	...
	}

	Single line if-statement:
	if condition { code }

	Maximum comment line length: 80 spaces
	Recommended maximum code line length: 96 spaces

	———— Documentation comments ————————————————————————————————————————————————
	/**
	Description

	- Parameters:
	- x: Description


	- Returns: Description
	*/

	———— Marks —————————————————————————————————————————————————————————————————
	Marks for rough code structuring:

	//
	////
	//////
	//"MARK": - Description
	//////
	////
	//

	————————————————————————————————————————————————————————————————————————————
*/
// swiftlint:disable file_length

#if os(Linux)
    import Glibc
    import CBSD
#endif
import Foundation

//
////
//////
//MARK: - Typealiases
//////
////
//

/*
	Limbs are basically single Digits in base 2^64. Each slot in an Limbs array
	stores one Digit of the number. The least significant digit is stored at
	index 0, the most significant digit is stored at the last index.
*/
typealias Limbs  = [UInt64]
typealias Limb   =  UInt64
/*
	A digit is a number in base 10^18. This is the biggest possible base that
	fits into an unsigned 64 bit number. Digits are required for printing BInt
	numbers. Limbs are converted into Digits first, and then printed.
*/
typealias Digits = [UInt64]
typealias Digit  =  UInt64

//
////
//////
//MARK: - BInt
//////
////
//

/// A multiple precision integer value type.
public struct BInt:
	ExpressibleByIntegerLiteral,
	ExpressibleByFloatLiteral,
	Comparable,
	Equatable,
	Hashable
{
	/*
		sign == true implies that Number is smaller than Zero. When no sign is
		provided, the number defaults to positive.
	*/
	internal var sign = false

	/*
		[] := undefined (error)
		[0] := 0, defined as positive
		[n] := n
		[k, l, ..., m] :=
		(k * 2^(0*64))
		+ (l * 2^(1*64))
		+ ...
		+ (m * 2^(i*64))
	*/
	internal var limbs = Limbs()

	/**
		Root initializer for all other initializers. Because no sign is
		provided, the new instance is positive by definition.
	*/
	internal init(limbs: Limbs)
	{
		precondition(limbs != [], "BInt can't be initialized with limbs == []")

		self.limbs = limbs
	}

	/// Create an instance initialized with a sign and a limbs array.
	internal init(sign: Bool, limbs: Limbs)
	{
		self.init(limbs: limbs)
		self.sign = sign
	}

	/// Create an instance initialized with the value 0.
	public init()
	{
		self.init(limbs: [0])
	}

	/// Create an instance initialized to an integer value.
	public init(_ z: Int)
	{
		if z == Int.min
		{
			/*
				Since abs(Int.min) == Int.max + 1, it is necessary to handle
				z == Int.min as a special case.
			*/
			self.init(sign: true, limbs: [Limb(Int.max) + 1])
		}
		else
		{
			/*
				The standard case, with limbs == abs(z) and a positive sign
				exactly when z is smaller than 0.
			*/
			self.init(sign: z < 0, limbs: [Limb(abs(z))])
		}
	}

	/// Create an instance initialized to an unsigned integer value.
	public init(_ n: UInt)
	{
		self.init(limbs: [Limb(n)])
	}

	/// Use a string to create a new BInt number.
	public init(_ str: String)
	{
		var str = str
		var sign = false
		var base: Limbs = [1]
		var limbs: Limbs = [0]
		limbs.reserveCapacity(Int(Double(str.count) / 19.2))

		if str.hasPrefix("-")
		{
			// The sign is true, but only if the number is not zero.

			str.remove(at: str.startIndex)
			sign = str != "0"
		}

		for char in str.reversed()
		{
			if let num = Limb(String(char))
			{
				multiplyLimbs(limbs: base, limb: num, addInto: &limbs)

				/*
					x * 10 equals x * 0b1010, therefore x * 10 equals
					(x * 8) + (x * 2) == (x << 3) + (x << 1).
					This makes the conversion a lot faster.
				*/

				base = (base <<° 3) +° (base <<° 1)
			}
			else
			{
				fatalError("Error: String must only consist of Digits (0-9)")
			}
		}

		self.init(sign: sign, limbs: limbs)
	}

	// Requierd to conform to FloatLiteralConvertible.
	public init(floatLiteral value: Double)
	{
		self.init(
			sign: value < 0,
			limbs: [Limb(value)]
		)
	}

	// Required to conform to IntegerLiteralConvertible.
	public init(integerLiteral value: Int)
	{
		self.init(value)
	}

	//
	////
	//////
	//MARK: - Struct functions
	//////
	////
	//

	/// Returns BInt value as an integer, if possible.
	public func toInt() -> Int?
	{
		/*
			Conversion only works when self has only one limb thats smaller or
			equal to abs(Int.min).
		*/
		if self.limbs.count == 1
		{
			let number = self.limbs[0]

			// Self is within the range of Int
			if number <= Limb(Int.max)
			{
				return self.sign ? -Int(number) : Int(number)
			}

			// Special case: self == Int.min
			if number == (Limb(Int.max) + 1) && self.sign
			{
				return Int.min
			}
		}

		return nil
	}

	public var rawValue: (sign: Bool, limbs: [UInt64])
	{
		return (self.sign, self.limbs)
	}

	public var hashValue: Int
	{
		return "\(self.sign)\(self.limbs)".hashValue
	}

	public func isPositive() -> Bool { return !self.sign             }
	public func isNegative() -> Bool { return self.sign              }
	public func isZero()     -> Bool { return self.limbs == [0]      }
	public func isOdd()      -> Bool { return self.limbs[0] & 1 == 1 }
	public func isEven()     -> Bool { return self.limbs[0] & 1 == 0 }

	public mutating func negate()
	{
		if self.limbs != [0] { self.sign = !self.sign }
	}
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
//MARK:    - Limb helper functions
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

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Shifting Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator <<=°
private func <<=°(lhs: inout Limbs, rhs: Int)
{
	// No shifting is required in this case
	if rhs == 0 || lhs == [0] { return }

	let limbShifts =  rhs >> 6
	let bitShifts = Limb(rhs) & 0x3f

	if bitShifts != 0
	{
		var oldCarry = Limb(0)
		var carry = Limb(0)

		for i in 0..<lhs.count
		{
			carry = lhs[i] >> (64 - bitShifts)

			lhs[i] <<= bitShifts
			lhs[i] |= oldCarry // carry from last step
			oldCarry = carry
		}

		if oldCarry != 0 { lhs.append(oldCarry) }
	}

	if limbShifts != 0
	{
		lhs.insert(contentsOf: Limbs(repeating: 0, count: limbShifts), at: 0)
	}
}

infix operator >>=°
private func >>=°(lhs: inout Limbs, rhs: Int)
{
	if rhs == 0 || lhs == [0] { return }

	let limbShifts =  rhs >> 6
	let bitShifts = Limb(rhs) & 0x3f

	if limbShifts >= lhs.count
	{
		lhs = [0]
		return
	}

	lhs.removeSubrange(0..<limbShifts)

	if bitShifts != 0
	{
		var previousCarry = Limb(0)
		var carry = Limb(0)

		var i = lhs.count - 1; while i >= 0
		{
			carry = lhs[i] << (64 &- bitShifts)

			lhs[i] >>= bitShifts
			lhs[i] |= previousCarry
			previousCarry = carry

			i -= 1
		}
	}

	if lhs.last! == 0 && lhs.count != 1 { lhs.removeLast() }
}

infix operator <<°
private func <<°(lhs: Limbs, rhs: Int) -> Limbs
{
	var lhs = lhs
	lhs <<=° rhs
	return lhs
}

infix operator >>°
private func >>°(lhs: Limbs, rhs: Int) -> Limbs
{
	var lhs = lhs
	lhs >>=° rhs
	return lhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for shifting BInts
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func <<(lhs: BInt, rhs: Int) -> BInt
{
	if rhs < 0 { return lhs >> rhs }

	let limbRes = lhs.limbs <<° rhs

	return BInt(
		sign: lhs.isNegative() && limbRes != [0],
		limbs: limbRes
	)
}

public func >>(lhs: BInt, rhs: Int) -> BInt
{
	if rhs < 0 { return lhs << rhs }

	return BInt(sign: lhs.sign, limbs: lhs.limbs >>° rhs)
}

public func <<=( lhs: inout BInt, rhs: Int)
{
	lhs.limbs <<=° rhs
}

public func >>=( lhs: inout BInt, rhs: Int)
{
	lhs.limbs >>=° rhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Adding Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func abs(_ lhs: BInt) -> BInt
{
	return BInt(
		sign: false,
		limbs: lhs.limbs
	)
}

infix operator ^^°
private func ^^°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	let size = max(lhs.count, rhs.count)
	var res = Limbs(repeating: 0, count: size)

	for i in 0..<size
	{
		if i >= lhs.count
		{
			res[i] = rhs[i]
		}
		else if i >= rhs.count
		{
			res[i] = lhs[i]
		}
		else
		{
			res[i] = lhs[i] ^ rhs[i]
		}
	}

	if res.count > 1 && res.last! == 0 { res.removeLast() }

	return res
}

infix operator &°
private func &°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	let size = min(lhs.count, rhs.count)
	var res = Limbs(repeating: 0, count: size)

	for i in 0..<size
	{
		res[i] = lhs[i] & rhs[i]
	}

	if res.count > 1 && res.last! == 0 { res.removeLast() }

	return res
}

private func addBInt(_ a: Limbs, _ b: Limbs) -> Limbs
{
	var res:    Limbs = a ^^° b
	var ovf:    Limbs = (a &° b) <<° 1
	var ovfNew: Limbs = [0]

	while ovf != [0]
	{
		ovfNew = (res &° ovf) <<° 1

		res = res ^^° ovf
		ovf = ovfNew
	}

	return res
}


private func addLimbs(_ lhs: inout Limbs, _ rhs: Limbs, rhsPaddingZeroLimbs pz: Int)
{
	let lhc = lhs.count
	if pz >= lhc
	{
		if pz != lhc
		{
			lhs.append(contentsOf: Limbs(repeating: 0, count: pz &- lhc))
		}
		lhs.append(contentsOf: rhs)
		return
	}
	let rhc = rhs.count &+ pz

	var (newLimb, ovfl) = (Limb(0), false)

	let min = lhc < rhc ? lhc : rhc

	var i = pz
	while i < min
	{
		if ovfl
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i &- pz])
			newLimb = newLimb &+ 1

			ovfl = ovfl || newLimb == 0
		}
		else
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i &- pz])
		}

		lhs[i] = newLimb
		i += 1
	}

	while ovfl
	{
		if i < lhc
		{
			if i < rhc
			{
				(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i &- pz])
				newLimb = newLimb &+ 1
				ovfl = ovfl || newLimb == 0
			}
			else
			{
				(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], 1)
			}

			lhs[i] = newLimb
		}
		else
		{
			if i < rhc
			{
				(newLimb, ovfl) = Limb.addWithOverflow(rhs[i &- pz], 1)
				lhs.append(newLimb)
			}
			else
			{
				lhs.append(1)
				return
			}
		}

		i += 1
	}

	if lhs.count < rhc
	{
		lhs.append(contentsOf: rhs.suffix(from: i &- pz))
	}
}

private func addOneLimbToLimbs(_ lhs: inout Limbs, _ rhs: Limb, rhsPaddingZeroLimbs pz: Int)
{
	let lhc = lhs.count
	if pz >= lhc
	{
		if pz != lhc
		{
			lhs.append(contentsOf: Limbs(repeating: 0, count: pz &- lhc))
		}
		lhs.append(rhs)
		return
	}

	// i < lhc
	var i = pz

	let (newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs)
	lhs[i] = newLimb

	while ovfl
	{
		i += 1

		if i < lhc
		{
			lhs[i] += 1
			if lhs[i] != 0 { return }
		}
		else
		{
			lhs.append(1)
			return
		}
	}
}

private func addTwoLimbsToLimbs(_ lhs: inout Limbs, _ rhsLo: Limb, _ rhsHi: Limb, rhsPaddingZeroLimbs pz: Int)
{
	let lhc = lhs.count
	if pz >= lhc
	{
		if pz != lhc
		{
			lhs.append(contentsOf: Limbs(repeating: 0, count: pz &- lhc))
		}
		lhs.append(contentsOf: [rhsLo, rhsHi])
		return
	}

	// i < lhc
	var i = pz

	var (newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhsLo)
	lhs[i] = newLimb

	i += 1

	if i < lhc
	{
		if ovfl
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhsHi)
			newLimb = newLimb &+ 1
			ovfl = ovfl || newLimb == 0
		}
		else
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhsHi)
		}

		lhs[i] = newLimb
	}
	else
	{
		if ovfl
		{
			newLimb = rhsHi &+ 1
			lhs.append(newLimb)

			if newLimb == 0 { lhs.append(1) }
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
			lhs[i] = lhs[i] &+ 1
			if lhs[i] != 0 { return }
		}
		else
		{
			lhs.append(1)
			return
		}
	}
}

infix operator +=°
/// Add limbs and wirte result in left Limbs
private func +=°(lhs: inout Limbs, rhs: Limbs)
{
	let lhc = lhs.count
	let rhc = rhs.count

	var (newLimb, ovfl) = (Limb(0), false)

	let min = lhc < rhc ? lhc : rhc

	var i = 0
	while i < min
	{
		if ovfl
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i])
			newLimb = newLimb &+ 1

			ovfl = ovfl || newLimb == 0
		}
		else
		{
			(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i])
		}

		lhs[i] = newLimb
		i += 1
	}

	while ovfl
	{
		if i < lhc
		{
			if i < rhc
			{
				(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], rhs[i])
				newLimb = newLimb &+ 1
				ovfl = ovfl || newLimb == 0
			}
			else
			{
				(newLimb, ovfl) = Limb.addWithOverflow(lhs[i], 1)
			}

			lhs[i] = newLimb
		}
		else
		{
			if i < rhc
			{
				(newLimb, ovfl) = Limb.addWithOverflow(rhs[i], 1)
				lhs.append(newLimb)
			}
			else
			{
				lhs.append(1)
				return
			}
		}

		i += 1
	}

	if lhs.count < rhc
	{
		lhs.append(contentsOf: rhs.suffix(from: i))
	}
}

infix operator +°
/// Adding Limbs and returning result
private func +°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	lhs +=° rhs
	return lhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Subtracting Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator -=°
/// Calculates difference between Limbs in left limb
private func -=°(lhs: inout Limbs, rhs: Limbs)
{
	var rhs = rhs
	// swap to get difference
	if lhs <° rhs { swap(&lhs, &rhs) }

	let rhc = rhs.count
	var ovfl = false

	var i = 0

	// cut first zeros
	while (i < rhc) && (rhs[i] == 0) { i += 1 }

	while i < rhc
	{
		if ovfl
		{
			(lhs[i], ovfl) = Limb.subtractWithOverflow(lhs[i], rhs[i])
			lhs[i] = lhs[i] &- 1
			ovfl = ovfl || lhs[i] == Limb.max
		}
		else
		{
			(lhs[i], ovfl) = Limb.subtractWithOverflow(lhs[i], rhs[i])
		}

		i += 1
	}

	while ovfl
	{
		if i >= lhs.count
		{
			lhs.append(UInt64.max)
			break
		}

		(lhs[i], ovfl) = Limb.subtractWithOverflow(lhs[i], 1)

		i += 1
	}

	if lhs.count > 1 && lhs.last! == 0 // cut excess zeros if required
	{
		var i = lhs.count - 2
		while i >= 1 && lhs[i] == 0 { i -= 1 }

		lhs.removeSubrange((i + 1)..<lhs.count)
	}
}

/// Calculating difference between Limbs with returning result
infix operator -°
private func -°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	lhs -=° rhs
	return lhs
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for adding BInts
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func +=(lhs: inout BInt, rhs: BInt)
{
	if lhs.sign == rhs.sign
	{
		lhs.limbs +=° rhs.limbs
		return
	}

	let c = rhs.limbs <° lhs.limbs
	lhs.limbs -=° rhs.limbs
	lhs.sign = (rhs.sign && !c) || (lhs.sign && c) // DNF minimization

	if lhs.isZero() { lhs.sign = false }
}

public func +(lhs: BInt, rhs: BInt) -> BInt
{
	var lhs = lhs
	lhs += rhs
	return lhs
}

public func +(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) + rhs }
public func +(lhs: BInt, rhs: Int) -> BInt { return lhs + BInt(rhs) }

public func +=(lhs: inout Int, rhs: BInt) { lhs += (BInt(lhs) + rhs).toInt()! }
public func +=(lhs: inout BInt, rhs: Int) { lhs +=  BInt(rhs)                 }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for subtracting BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public prefix func -(n: BInt) -> BInt
{
	var n = n
	n.negate()
	return n
}

public func -(lhs: BInt, rhs: BInt) -> BInt
{
	return lhs + -rhs
}

public func -(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) - rhs }
public func -(lhs: BInt, rhs: Int) -> BInt { return lhs - BInt(rhs) }

public func -=(lhs: inout BInt, rhs: BInt) { lhs +=             -rhs           }
public func -=(lhs: inout Int, rhs: BInt)  { lhs  = (BInt(lhs) - rhs).toInt()! }
public func -=(lhs: inout BInt, rhs: Int)  { lhs -=         BInt(rhs)          }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Multiply Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

private func mul(res: inout Limbs, limbs lhs: Limbs, limbs rhs: Limbs)
{
	res.reserveCapacity(lhs.count + rhs.count)

	var overflow: Bool
	var mulLo, mulHi, l, r,
		lLo, lHi, rLo, rHi,
		lrMi, rlMi: Limb

	for i in 0..<lhs.count
	{
		l = lhs[i]
		if l == 0 { continue }

		for j in 0..<rhs.count
		{
			r = rhs[j]
			if r == 0 { continue }

			(mulLo, overflow) = Limb.multiplyWithOverflow(l, r)

			if overflow
			{
				/*
				128 bit multiplication with low and high part
				*/

				(lLo, lHi) = (l & 0xffff_ffff, l >> 32)
				(rLo, rHi) = (r & 0xffff_ffff, r >> 32)
				(lrMi, rlMi) = (lLo * rHi, rLo * lHi)

				// Carry
				mulHi = (lLo * rLo) >> 32
				mulHi += lrMi & 0xffff_ffff
				mulHi += rlMi & 0xffff_ffff
				mulHi >>= 32

				mulHi += lHi * rHi
				mulHi += lrMi >> 32
				mulHi += rlMi >> 32

				addTwoLimbsToLimbs(&res, mulLo, mulHi, rhsPaddingZeroLimbs: i + j)
			}
			else
			{
				addOneLimbToLimbs(&res, mulLo, rhsPaddingZeroLimbs: i + j)
			}
		}
	}
}

private func multiplyLimbs(limbs lhs: Limbs, limb r: Limb, addInto res: inout Limbs)
{
	if r < 2
	{
		if r == 1 { res +=° lhs }
		return
	}

	var overflow: Bool
	var mulLo, mulHi, l,
	lLo, lHi, rLo, rHi,
	lrMi, rlMi: Limb

	for i in 0..<lhs.count
	{
		l = lhs[i]
		if l == 0 { continue }

		(mulLo, overflow) = Limb.multiplyWithOverflow(l, r)

		if overflow
		{
			/*
			128 bit multiplication with low and high part
			*/

			(lLo, lHi) = (l & 0xffff_ffff, l >> 32)
			(rLo, rHi) = (r & 0xffff_ffff, r >> 32)
			(lrMi, rlMi) = (lLo * rHi, rLo * lHi)

			// Carry
			mulHi = (lLo * rLo) >> 32
			mulHi += lrMi & 0xffff_ffff
			mulHi += rlMi & 0xffff_ffff
			mulHi >>= 32

			mulHi += lHi * rHi
			mulHi += lrMi >> 32
			mulHi += rlMi >> 32

			addTwoLimbsToLimbs(&res, mulLo, mulHi, rhsPaddingZeroLimbs: i)
		}
		else
		{
			addOneLimbToLimbs(&res, mulLo, rhsPaddingZeroLimbs: i)
		}
	}
}



infix operator *°
private func *°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var res: Limbs = [0]

	mul(res: &res, limbs: lhs, limbs: rhs)
	return res
}

func square(res: inout Limbs, limbs lhs: Limbs)
{
	res.reserveCapacity(2 * lhs.count)

	var overflow: Bool
	var mulLo, mulHi, l, r,
		lLo, lHi, rLo, rHi,
		lrMi, rlMi: Limb

	for i in 0..<lhs.count
	{
		l = lhs[i]
		if l == 0 { continue }

		for j in 0...i
		{
			r = lhs[j]
			if r == 0 { continue }

			(mulLo, overflow) = Limb.multiplyWithOverflow(l, r)

			if overflow
			{
				/*
				128 bit multiplication with low and high part
				*/

				(lLo, lHi) = (l & 0xffff_ffff, l >> 32)
				(rLo, rHi) = (r & 0xffff_ffff, r >> 32)
				(lrMi, rlMi) = (lLo * rHi, rLo * lHi)

				// Carry
				mulHi = (lLo * rLo) >> 32
				mulHi += lrMi & 0xffff_ffff
				mulHi += rlMi & 0xffff_ffff
				mulHi >>= 32

				mulHi += lHi * rHi
				mulHi += lrMi >> 32
				mulHi += rlMi >> 32

				if i != j { addTwoLimbsToLimbs(&res, mulLo, mulHi, rhsPaddingZeroLimbs: i + j) }
				addTwoLimbsToLimbs(&res, mulLo, mulHi, rhsPaddingZeroLimbs: i + j)
			}
			else
			{
				if i != j { addOneLimbToLimbs(&res, mulLo, rhsPaddingZeroLimbs: i + j) }
				addOneLimbToLimbs(&res, mulLo, rhsPaddingZeroLimbs: i + j)
			}
		}
	}
}

// square
postfix operator ^^
private postfix func ^^(lhs: Limbs) -> Limbs
{
	var res: Limbs = [0]
	res.reserveCapacity(2 * lhs.count)

	square(res: &res, limbs: lhs)

	return res
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for multiplying BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func *(lhs: BInt, rhs: BInt) -> BInt
{
	let sign = !(lhs.sign == rhs.sign || lhs.isZero() || rhs.isZero())
	return BInt(sign: sign, limbs: lhs.limbs *° rhs.limbs)
}

public func *(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) * rhs }
public func *(lhs: BInt, rhs: Int) -> BInt { return lhs * BInt(rhs) }

public func *=(lhs: inout BInt, rhs:BInt) { lhs =       lhs  * rhs          }
public func *=(lhs: inout Int, rhs: BInt) { lhs = (BInt(lhs) * rhs).toInt()! }
public func *=(lhs: inout BInt, rhs: Int) { lhs =       lhs  * BInt(rhs)    }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Exponentiation of Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

// Exponentiation by squaring
infix operator ^°
private func ^°(lhs: Limbs, rhs: Int) -> Limbs
{
	if rhs == 0 { return [1] }
	if rhs == 1 { return lhs }

	var lhs = lhs
	var rhs = rhs
	var y: Limbs = [1]

	while rhs > 1
	{
		if rhs & 1 != 0 { y = y *° lhs }

		lhs = lhs^^
		rhs >>= 1
	}

	return lhs *° y

}



/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for exponentiation of BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func ^(lhs: BInt, rhs: Int) -> BInt
{
	precondition(rhs >= 0, "BInts can't be exponentiated with exponents < 0")

	return BInt(sign: lhs.sign && ((rhs & 1) == 1), limbs: lhs.limbs ^° rhs)
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Modulo for Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator %°
private func %°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	precondition(rhs != [0], "Modulo by zero not allowed")

	var lhs = lhs
	if lhs <° rhs { return lhs }
	if rhs == [1] { return [0] }

	if lhs.count == 1 && rhs.count == 1
	{
		return [lhs[0] % rhs[0]]
	}

	var accList = [rhs]

	// get maximum required exponent size
	while  accList.last! <° lhs
	{
		accList.append(accList.last! <<° 3)
		// 3 because seems to be fastest
	}

	// iterate through exponents and subract if needed

	var i = accList.count - 1 // -1 because last > lhs
	while i >= 0
	{
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
		}

		i -= 1
	}

	return lhs
}

private func modLimbs(_ lhs: inout Limbs, _ rhs: Limbs)
{
	precondition(rhs != [0], "Modulo by zero not allowed")
	if lhs <° rhs { return }
	if rhs == [1] { lhs = [0]; return }

	if lhs.count == 1 && rhs.count == 1
	{
		lhs[0] = lhs[0] % rhs[0]
		//lhs[0] %= rhs[0]
		return
	}

	var accList = [rhs]

	// get maximum required exponent size
	while  accList.last! <° lhs
	{
		accList.append(accList.last! <<° 3)
		// 3 because seems to be fastest
	}

	// iterate through exponents and subract if needed
	var i = accList.count - 1 // -1 because last > lhs
	while i >= 0
	{
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
		}

		i -= 1
	}
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for modulo calculations with BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func %(lhs: BInt, rhs: BInt) -> BInt
{
	let limbs = lhs.limbs %° rhs.limbs
	let sign = lhs.sign && limbs != [0]

	return BInt(sign: sign, limbs: limbs)
}

public func %(lhs: Int, rhs: BInt) -> BInt { return BInt(lhs) % rhs }
public func %(lhs: BInt, rhs: Int) -> BInt { return lhs % BInt(rhs) }

public func %=(lhs: inout BInt, rhs: BInt)
{
	modLimbs(&lhs.limbs, rhs.limbs)
	lhs.sign = lhs.sign && lhs.limbs != [0]
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Division for Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

infix operator /°
/// Division with limbs, result is floored to nearest whole number
private func /°(lhs: Limbs, rhs: Limbs) -> Limbs
{
	var lhs = lhs
	// cover base cases
	precondition(rhs != [0], "Division by zero")
	if lhs <° rhs { return [0] }
	if rhs == [1] { return lhs }
	if lhs == rhs { return [1] }

	if lhs.count == 1 && rhs.count == 1 // for small numbers
	{
		return [lhs[0] / rhs[0]]
	}

	var accList = [rhs]
	var divList: [Limbs] = [[Limb(1)]]

	// get maximum required exponent size
	while  accList.last! <° lhs
	{
		accList.append(accList.last! <<° 3)
		divList.append(divList.last! <<° 3)
		// 3 because seems to be fastest
	}

	var div = [Limb(0)]

	// iterate through exponents and subract if needed
	var i = accList.count - 1 // -1 because last > lhs
	while i >= 0
	{
		var times = 0
		while !(lhs <° accList[i]) // accList[i] <= lhs
		{
			lhs -=° accList[i]
			times += 1
			//div +=° divList[i]
		}
		div +=° (divList[i] *° [Limb(times)])

		i -= 1
	}

	return div
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for division with BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func /(lhs: BInt, rhs:BInt) -> BInt
{
	let limbs = lhs.limbs /° rhs.limbs
	let sign = (lhs.sign != rhs.sign) && limbs != [0]

	return BInt(sign: sign, limbs: limbs)
}

public func /=(lhs: inout BInt, rhs: BInt) { lhs = lhs / rhs }

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Comparing Limbs (° indicates operation on Limbs)
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

// ==° and !=° not required, work by default

/*
Important:
a < b <==> b > a
a <= b <==> b >= a
but:
a < b <==> !(a >= b)
a <= b <==> !(a > b)
*/

infix operator <°
private func <°(lhs: Limbs, rhs: Limbs) -> Bool
{
	if lhs.count != rhs.count
	{
		return lhs.count < rhs.count
	}

	var i = lhs.count - 1
	while i >= 0
	{
		if lhs[i] != rhs[i] { return lhs[i] < rhs[i] }

		i -= 1
	}


	return false // case equal
}

/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
//MARK: - Public operators for comparing BInt's
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public func ==(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return false }
	return lhs.limbs == rhs.limbs
}

public func ==(lhs: Int, rhs: BInt) -> Bool { return BInt(lhs) == rhs }
public func ==(lhs: BInt, rhs: Int) -> Bool { return lhs == BInt(rhs) }


public func !=(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return true }
	return lhs.limbs != rhs.limbs
}

public func !=(lhs: Int, rhs: BInt) -> Bool { return BInt(lhs) != rhs }
public func !=(lhs: BInt, rhs: Int) -> Bool { return lhs != BInt(rhs) }


public func <(lhs: BInt, rhs: BInt) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign   }
	if lhs.sign { return rhs.limbs <° lhs.limbs }

	return lhs.limbs <° rhs.limbs
}

public func <(lhs: Int, rhs: BInt) -> Bool { return BInt(lhs) < rhs }
public func <(lhs: BInt, rhs: Int) -> Bool { return lhs < BInt(rhs) }


public func >(lhs: BInt, rhs: BInt) -> Bool
{
	return rhs < lhs
}

public func >(lhs: Int, rhs: BInt) -> Bool { return BInt(lhs) > rhs }
public func >(lhs: BInt, rhs: Int) -> Bool { return lhs > BInt(rhs) }


public func <=(lhs: BInt, rhs: BInt) -> Bool
{
	return !(rhs < lhs)
}

public func <=(lhs: Int, rhs: BInt) -> Bool { return BInt(lhs) <= rhs }
public func <=(lhs: BInt, rhs: Int) -> Bool { return lhs <= BInt(rhs) }


public func >=(lhs: BInt, rhs: BInt) -> Bool
{
	return !(lhs < rhs)
}

public func >=(lhs: Int, rhs: BInt) -> Bool { return BInt(lhs) >= rhs }
public func >=(lhs: BInt, rhs: Int) -> Bool { return lhs >= BInt(rhs) }

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
//MARK:    - Pre-implemented optimized math functions
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

private func factRec(_ left: Int, _ right: Int) -> Limbs
{
	if left >= right - 1
	{
		return [Limb(right)]
	}

	let mid = (left + right) / 2

	return factRec(left, mid) *° factRec(mid, right)
}

private func factPrime(_ n: Int) -> Limbs
{
	if n < 3 { return [Limb(n)] }

	var primeOccurs = [Int : Int]()


	benchmarkPrint(title: "dict ops")
	{
		for i in 2...n
		{
			let factors = factorize(i)

			for factor in factors
			{
				if primeOccurs[factor] != nil
				{
					primeOccurs[factor]! += 1
				}
				else
				{
					primeOccurs[factor] = 1
				}
			}
		}
	}

	var res: Limbs = [1]
	for (prime, count) in primeOccurs
	{
		res = res *° ([Limb(prime)] ^° count)
	}

	return res
}

public func fact(_ n: Int) -> BInt
{
	return BInt(limbs: factRec(1, n))
}

private func lucLehMod(_ n: Int, _ mod: Limbs) -> Limbs
{
	var res: Limbs = [4]

	for _ in 0..<(n - 1)
	{
		res = ((res^^) -° [2]) %° mod
	}

	return res
}

public func isMersenne(_ exp: Int) -> Bool
{
	var mersenne = Limbs(repeating: Limb.max, count: exp >> 6)
	let v = (Limb(1) << Limb(exp % 64)) - Limb(1)
	if (exp % 6) > 0 { mersenne.append(v) }

	return lucLehMod(exp - 1, mersenne) == [0]
}

private func gcdFactors(_ lhs: Limbs, rhs: Limbs) -> (ax: Limbs, bx: Limbs)
{
	let gcd = euclid(lhs, rhs)

	return (lhs /° gcd, rhs /° gcd)
}

private func euclid(_ a: Limbs, _ b: Limbs) -> Limbs
{
	var a = a
	var b = b
	while b != [0]
	{
		(a, b) = (b, a %° b)
	}

	return a
}

public func steinGcd(_ a: BInt, _ b: BInt) -> BInt
{
	if a.isZero() { return b }

	var a = a
	var b = b
	var k = 0

	while a.isEven() && b.isEven()
	{
		a = a >> 1
		b = b >> 1
		k += 1
	}

	var t = BInt(0)


	if a.isOdd()
	{
		t = -b
	}
	else
	{
		t = a
	}

	while !t.isZero()
	{
		while t.isEven()
		{
			t = t >> 1
		}

		if  t > 0
		{
			a = t
		}
		else
		{
			b = -t
		}

		t = a - b
	}

	return a << k
}

public func gcd(_ a: BInt, _ b: BInt) -> BInt
{
	let limbRes = euclid(a.limbs, b.limbs)
	return BInt(sign: a.sign && limbRes != [0], limbs: limbRes)
}

private func lcmPositive(_ a: Limbs, _ b: Limbs) -> Limbs
{
	return (a /° euclid(a, b)) *° b
}

public func lcm(_ a:BInt, _ b:BInt) -> BInt
{
	return BInt(limbs: lcmPositive(a.limbs, b.limbs))
}

public func fib(_ n:Int) -> BInt
{
	var a: Limbs = [0]
	var b: Limbs = [1]

	for _ in 2...n
	{
		let t = b
		b +=° a
		a = t
	}

	return BInt(limbs: b)
}

public func permutations(_ n: Int, _ k: Int) -> BInt
{
	return BInt(limbs: factRec(n - k, n))
}

public func combinations(_ n: Int, _ k: Int) -> BInt
{
	return BInt(limbs: factRec(n - k, n) /° factRec(1, k))
}

public func randomBInt(bits n: Int) -> BInt
{
	let limbs = n >> 6
	let singleBits = n % 64

	var res = Limbs(repeating: 0, count: Int(limbs))

	for i in 0..<Int(limbs)
	{
		res[i] = Limb(arc4random_uniform(UInt32.max)) |
			(Limb(arc4random_uniform(UInt32.max)) << 32)
	}

	if singleBits > 0
	{
		var last: Limb

		if singleBits < 32
		{
			last = Limb(arc4random_uniform(UInt32(2 ** singleBits)))

		}
		else if singleBits == 32
		{
			last = Limb(arc4random_uniform(UInt32.max))
		}
		else
		{
			last = Limb(arc4random_uniform(UInt32.max)) |
				(Limb(arc4random_uniform(UInt32(2 ** (singleBits - 32)))) << 32)
		}

		res.append(last)
	}

	return BInt(limbs: res)
}

func isPrime(_ n: BInt) -> Bool
{
	if n <= 3 { return n > 1 }

	if ((n % 2) == 0) || ((n % 3) == 0) { return false }

	var i = 5
	while (i * i) <= n
	{
		if ((n % i) == 0) || ((n % (i + 2)) == 0)
		{
			return false
		}
		i += 6
	}
	return true
}


/// Quick exponentiation/modulo algorithm
/// FIXME: for security, this should use the constant-time Montgomery algorithm to thwart timing attacks
///
/// - Parameters:
///   - b: base
///   - p: power
///   - m: modulus
/// - Returns: pow(b, p) % m
public func mod_exp(_ b: BInt, _ p: BInt, _ m: BInt) -> BInt {
	precondition(m != 0, "modulus needs to be non-zero")
	precondition(p >= 0, "exponent needs to be non-negative")
	var base = b % m
	var exponent = p
	var result = Bignum(1)
	while exponent > 0 {
		if exponent.limbs[0] % 2 != 0 {
			result = result * base % m
		}
		exponent.limbs >>=° 1
		base *= base
		base %= m
	}
	return result
}


/// Non-negative modulo operation
///
/// - Parameters:
///   - a: left hand side of the module operation
///   - m: modulus
/// - Returns: r := a % b such that 0 <= r < abs(m)
public func nnmod(_ a: BInt, _ m: BInt) -> BInt {
	let r = a % m
	guard r.isNegative() else { return r }
	let p = m.isNegative() ? r - m : r + m
	return p
}


/// Convenience function combinding addition and non-negative modulo operations
///
/// - Parameters:
///   - a: left hand side of the modulo addition
///   - b: right hand side of the modulo addition
///   - m: modulus
/// - Returns: nnmod(a + b, m)
public func mod_add(_ a: BInt, _ b: BInt, _ m: BInt) -> BInt {
	return nnmod(a + b, m)
}


/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/
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
//MARK:    - BDouble
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
/*\
/**\
/***\
/****\
/*****\
/******\
/*******\
\*******/
\******/
\*****/
\****/
\***/
\**/
\*/

public struct BDouble:
	ExpressibleByIntegerLiteral,
	ExpressibleByFloatLiteral,
	Comparable,
	Equatable,
	Hashable
{
	var sign = Bool()
	var numerator = Limbs()
	var denominator = Limbs()

	/**
	Inits a BDouble with two Limbs as numerator and denominator

	- Parameters:
	- numerator: The upper part of the fraction as Limbs
	- denominator: The lower part of the fraction as Limbs

	Returns: A new BDouble
	*/

	init(sign: Bool, numerator: Limbs, denominator: Limbs)
	{
		precondition(
			denominator != [0] && denominator != [] && numerator != [],
			"Denominator can't be zero and limbs can't be []"
		)

		self.sign = sign
		self.numerator = numerator
		self.denominator = denominator

		self.minimize()
	}

	init(_ numerator: BInt, over denominator: BInt)
	{
		self.init(
			sign:			numerator.sign != denominator.sign,
			numerator:		numerator.limbs,
			denominator:	denominator.limbs
		)
	}

	init(_ numerator: Int, over denominator: Int)
	{
		self.init(
			sign: (numerator < 0) != (denominator < 0),
			numerator: [UInt64(abs(numerator))],
			denominator: [UInt64(abs(denominator))]
		)
	}

	init(_ numerator: String, over denominator: String)
	{
		self.init(BInt(numerator), over: BInt(denominator))
	}

	public init(_ z: Int)
	{
		self.init(z, over: 1)
	}

	public init(_ d: Double)
	{
		let nStr = String(d)

		if let exp = nStr[Character("e")]
		{
			let beforeExp = String(nStr[0..<exp].filter{ $0 != "." })
			var afterExp = nStr[(exp + 1)..<nStr.count]
			var sign = false

			if let neg = afterExp[Character("-")]
			{
				afterExp = afterExp[(neg + 1)..<afterExp.count]
				sign = true
			}

			if sign
			{
				let den = ["1"] + [Character](repeating: "0", count: Int(afterExp)!)
				self.init(beforeExp, over: String(den))
				return
			}
			else
			{
				let num = beforeExp + String([Character](repeating: "0", count: Int(afterExp)!))
				self.init(num, over: "1")
				return
			}
		}

		let i = nStr["."]!
		let beforePoint = nStr[0..<i]

		let afterPoint = nStr[(i + 1)..<nStr.count]

		if afterPoint == "0"
		{
			self.init(beforePoint, over: "1")
		}
		else
		{
			let den = ["1"] + [Character](repeating: "0", count: afterPoint.count)
			self.init(beforePoint + afterPoint, over: String(den))
		}
	}

	public init(integerLiteral value: Int)
	{
		self.init(value)
	}

	public init(floatLiteral value: Double)
	{
		self.init(value)
	}

	public var hashValue: Int
	{
		return "\(self.sign)\(self.numerator)\(self.denominator)".hashValue
	}

	public func rawData() -> (sign: Bool, numerator: [UInt64], denominator: [UInt64])
	{
		return (self.sign, self.numerator, self.denominator)
	}

	public func isPositive() -> Bool { return !self.sign }
	public func isNegative() -> Bool { return self.sign }
	public func isZero() -> Bool { return self.numerator == [0] }

	public mutating func negate()
	{
		if !self.isZero()
		{
			self.sign = !self.sign
		}
	}

	public mutating func minimize()
	{
		if self.numerator == [0]
		{
			self.denominator = [1]
			return
		}

		let gcd = euclid(self.numerator, self.denominator)

		if gcd[0] > 1 || gcd.count > 1
		{
			self.numerator = self.numerator /° gcd
			self.denominator = self.denominator /° gcd
		}
	}
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
//MARK:    - BDouble Operators, needs to be more!
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


public func ==(lhs: BDouble, rhs: BDouble) -> Bool
{
	if lhs.sign != rhs.sign { return false }
	if lhs.numerator != rhs.numerator { return false }
	if lhs.denominator != rhs.denominator { return false }

	return true
}

public func !=(lhs: BDouble, rhs: BDouble) -> Bool
{
	return !(lhs == rhs)
}

public func <(lhs: BDouble, rhs: BDouble) -> Bool
{
	if lhs.sign != rhs.sign { return lhs.sign }

	// more efficient than lcm version
	let ad  = lhs.numerator *° rhs.denominator
	let bc = rhs.numerator *° lhs.denominator

	if lhs.sign { return bc <° ad }

	return ad <° bc
}

public func  >(lhs: BDouble, rhs: BDouble) -> Bool { return rhs < lhs }
public func <=(lhs: BDouble, rhs: BDouble) -> Bool { return !(rhs < lhs) }
public func >=(lhs: BDouble, rhs: BDouble) -> Bool { return !(lhs < rhs) }




public func *(lhs: BDouble, rhs: BDouble) -> BDouble
{
	var res =  BDouble(
		sign:			lhs.sign != rhs.sign,
		numerator:		lhs.numerator *° rhs.numerator,
		denominator:	lhs.denominator *° rhs.denominator
	)

	if res.isZero() { res.sign = false }
	return res
}

func /(lhs: BDouble, rhs: BDouble) -> BDouble
{
	var res =  BDouble(
		sign:			lhs.sign != rhs.sign,
		numerator:		lhs.numerator *° rhs.denominator,
		denominator:	lhs.denominator *° rhs.numerator
	)

	if res.isZero() { res.sign = false }
	return res
}



public func +(lhs: BDouble, rhs: BDouble) -> BDouble
{
	let ad = lhs.numerator *° rhs.denominator
	let bc = rhs.numerator *° lhs.denominator
	let bd = lhs.denominator *° rhs.denominator

	let resNumerator = BInt(sign: lhs.sign, limbs: ad) + BInt(sign: rhs.sign, limbs: bc)

	return BDouble(
		sign: resNumerator.sign && resNumerator.limbs != [0],
		numerator: resNumerator.limbs,
		denominator: bd
	)
}

public prefix func -(n: BDouble) -> BDouble
{
	var n = n
	n.negate()
	return n
}

public func -(lhs: BDouble, rhs: BDouble) -> BDouble
{
	return lhs + -rhs
}

public func abs(_ lhs: BDouble) -> BDouble
{
	return BDouble(
		sign: false,
		numerator: lhs.numerator,
		denominator: lhs.denominator
	)
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
//MARK:    - Useful extenstions to the Swift language (required)
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

public extension String
{
	/// Returns character at index i as String.
	subscript(i: Int) -> String
	{
		return String(self[index(startIndex, offsetBy: i)])
	}

	/// Returns characters in range as string.
	subscript(r: Range<Int>) -> String
	{
		let start = index(startIndex, offsetBy: r.lowerBound)
		let end = index(start, offsetBy: r.upperBound - r.lowerBound)

		return self[start..<end]
	}

	/// If possible, returns index of first ocurrence of char.
	subscript(char: Character) -> Int?
	{
		if let idx = self.index(of: char)
		{
			return self.distance(from: self.startIndex, to: idx)
		}
		return nil
	}
}

infix operator **
public extension Int
{
	static func **(lhs: Int, rhs: Int) -> Int
	{
		if rhs == 0 { return 1 }
		var res = lhs

		for _ in 0..<(rhs - 1)
		{
			res *= lhs
		}

		return res
	}
}
