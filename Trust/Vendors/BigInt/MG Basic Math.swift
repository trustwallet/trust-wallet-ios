/*
	————————————————————————————————————————————————————————————————————————————
	MG Basic Math.swift
	————————————————————————————————————————————————————————————————————————————
	Created by Marcel Kröker on 03.04.15.
	Copyright (c) 2016 Blubyte. All rights reserved.
*/
#if os(Linux)
    import Glibc
    import CBSD
#endif
import Foundation

func binomial(_ n: Int, _ k: Int) -> Int
{
	return k == 0 ? 1 : n == 0 ? 0 : binomial(n - 1, k) + binomial(n - 1, k - 1)
}

func kronecker(_ i: Int, j: Int) -> Int
{
	return i == j ? 1 : 0
}

func numlen(_ n: Int) -> Int
{
	if n == 0 { return 1 }
	return Int(log10(Double(abs(n)))) + 1
}

func isPrime(_ n: Int) -> Bool
{
	if n <= 3 { return n > 1 }

	if n % 2 == 0 || n % 3 == 0 { return false }

	var i = 5
	while i * i <= n
	{
		if n % i == 0 || n % (i + 2) == 0
		{
			return false
		}
		i += 6
	}
	return true
}

/**
	Returns the n-th prime number.
*/
func getPrime(_ n: Int) -> Int
{
	precondition(n > 0, "There is no 0-th prime number")

	var prime = 2
	var primeCount = 1

	while primeCount != n
	{
		prime += 1
		if isPrime(prime) { primeCount += 1 }
	}

	return prime
}


/**
	Works with the Sieve of Eratosthenes.
*/
public func primesTo(_ n: Int) -> [Int]
{
	if n < 2 { return [] }

	var A = [Bool](repeating: true, count: n)

	var i = 2
	while i * i <= n
	{
		if A[i - 1]
		{
			var j = i * i
			var c = 1
			while j <= n
			{
				A[j - 1] = false
				j = i * (i + c)
				c += 1
			}
		}
		i += 1
	}

	var res = [2]

	i = 3
	while i <= n
	{
		if A[i - 1] { res.append(i) }
		i += 2
	}

	return res
}

func nextPrime( _ n: inout Int)
{
	repeat
	{
		n += 1
	}
	while !isPrime(n)
}

// Returns random Int within range
func random(_ range: Range<Int>) -> Int
{
    let offset = Int(range.lowerBound)
    let delta = UInt32(range.upperBound - range.lowerBound)

    return offset + Int(arc4random_uniform(delta))
}

// Neccessary for (...) to work
func random(_ range: ClosedRange<Int>) -> Int
{
	return random(Range(range))
}

// Returns array filled with n random Ints within range
func random(_ range: Range<Int>, _ count: Int) -> [Int]
{
	var res = [Int](repeating: 0, count: count)

    for i in 0..<count
    {
        res[i] = random(range)
    }
    return res
}

enum LetterSet
{
	case lowerCase
	case upperCase
	case numbers
	case specialSymbols
	case all
}

/**
	Creates a random String from one or multiple sets of
	letters.

	- Parameter length: Number of characters in random string.

	- Parameter letterSet: Specify desired letters as variadic
	parameters:
		- .All
		- .Numbers
		- .LowerCase
		- .UpperCase
		- .SpecialSymbols
*/
func randomString(_ length: Int, letterSet: LetterSet...) -> String
{
	var letters = [String]()
	var ranges = [CountableClosedRange<Int>]()

	for ele in letterSet
	{
		switch ele
		{
		case .all:
			ranges.append(33...126)

		case .numbers:
			ranges.append(48...57)

		case .lowerCase:
			ranges.append(97...122)

		case .upperCase:
			ranges.append(65...90)

		case .specialSymbols:
			ranges += [33...47, 58...64, 91...96, 123...126]
		}
	}

	for range in ranges
	{
		for i in range
		{
			letters.append(String(describing: UnicodeScalar(i)))
		}
	}

	var res = ""

	for _ in 0..<length
	{
		res += letters[random(0..<letters.count)]
	}
	
	return res
}

func gcd(_ a: Int, _ b: Int) -> Int
{
    if b == 0 { return a }
    return gcd(b, a % b)
}

func lcm(_ a: Int, _ b: Int) -> Int
{
    return (a / gcd(a, b)) * b
}

func factorize(_ n: Int) -> [Int]
{
	if isPrime(n) || n == 1 { return [n] }

	var n = n
	var res = [Int]()
	var nthPrime = 1

	while true
	{
		nextPrime(&nthPrime)

		while n % nthPrime == 0
		{
			n /= nthPrime
			res.append(nthPrime)

			if isPrime(n)
			{
				res.append(n)
				return res
			}
		}
	}
}
