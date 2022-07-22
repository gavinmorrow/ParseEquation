import Foundation

public struct ParseEquation {
	/// An enum that represents a block in an equation.
	///
	/// This enum is recursive, nesting `Symbol`s within.
	public indirect enum Block {
		case number(value: Double)
		case symbol(value: Symbol)
	}
	
	/// An enum that represents a mathematical operator.
	///
	/// This is recursive, nesting `Block`s for the left- and right-hand sides.
	public indirect enum Symbol {
		/// Represents the sum of two `Block`s
		case sum(lhs: Block, rhs: Block)
		
		/// Represents the difference of two `Block`s
		case difference(lhs: Block, rhs: Block)
		
		/// Represents the product of two `Block`s
		case product(lhs: Block, rhs: Block)
		
		/// Represents the quotient of two `Block`s
		case quotient(lhs: Block, rhs: Block)
		
		/// The associated values for the `Symbol`.
		var value: (lhs: Block, rhs: Block) {
			switch self {
				case .sum(lhs: let lhs, rhs: let rhs),
						.difference(lhs: let lhs, rhs: let rhs),
						.product(lhs: let lhs, rhs: let rhs),
						.quotient(lhs: let lhs, rhs: let rhs):
					return (lhs, rhs)
			}
		}
	}
	
	/// Get the `Block` that represents the equation.
	///
	/// Any non-valid characters will be stripped.
	///
	/// **Valid Characters**:
	/// - Valid `Double`s
	/// - `+`, `-`, `*`, `/` operators.
	///
	/// - Parameter for: The equation to parse.
	/// - Important: The equation can only have addition, subtraction, multiplication, and division.
	/// - Returns: The `Block` representing the equation,
	/// or `0` (as a `Block`) if the equation doesn't have any valid characters.
	public func getBlock(for equationParam: String) -> Block {
		// Ensure only valid characters are in the equation.
		let equation = equationParam.filter { char in
			let isValid = String(char).range(of: #"\d|.|+|-|*|/"#, options: .regularExpression) != nil
			
			if !isValid {
				print("WARNING: A non-valid character (\"\(char)\") was found in the equation \"\(equationParam)\".")
			}
			
			return isValid
		}
		
		// Ensure the equation has some content.
		guard !equation.isEmpty else { return .number(value: 0) }
		
		/// Extract a number from a string.
		///
		/// - Precondition: The number must begin at the start
		/// of the string.
		/// - Precondition: The number must be positive.
		func extractNumber(string: String) -> String {
			var numString = ""
			
			// Until the character isn't a valid number character, add a digit to the number.
			// The number can only be positive because of the challenges of determining
			// whether or not the "-" is negative or minus.
			for char in string {
				if String(char).range(
					of: #"\d|\."#,
					options: .regularExpression
				) != nil {
					numString += String(char)
				} else {
					break
				}
			}
			
			return numString
		}
		
		// Get the first number in the equation.
		// An equation **must** begin with a number.
		var firstNumString = ""
		
		// Allow the number to be negative.
		// This is how the positivity limitation
		// of `extractNumber` is handled.
		if equation.first == "-" {
			firstNumString = "-"
			// Drop the first digit b/c the "-" is already accounted for.
			firstNumString += extractNumber(string: String(equation.dropFirst()))
		} else {
			firstNumString += extractNumber(string: equation)
		}
		
		/// The first number as a `Double`, rather than a `String`
		let firstNum = Double(firstNumString) ?? 0
		
		let symbolString = String(
			equation
				.components(separatedBy: firstNumString)
				.dropFirst() // Drop the first b/c the first one will be empty.
				.joined(separator: "")
				.first ?? Character("#") // The "#" will be the end of the equation.
		)
		
		// Logs
		print("Equation: \(equation)")
		print("First Number: \(firstNum)")
		print("First Symbol: \(symbolString)")
		print("") // Newline
		
		// Get the next part to recursively parse the equation.
		/// The part of the equation after the part that has been parsed
		let nextPart = String(
			equation
				.components(separatedBy: firstNumString + symbolString)
				.dropFirst() // The first entry will be empty
				.joined(separator: "") // Join in case there's more than one of the subequation
		)
		
		// It's ok to make it an implicity unwrapped optional
		// because if it is nil, it won't be accessed.
		let rhs: Block! = symbolString == "#" ? nil : getBlock(for: nextPart)
		let lhs: Block  = .number(value: firstNum)
		
		let symbol: Symbol
		switch symbolString {
			case "+":
				symbol = .sum(lhs: lhs, rhs: rhs)
			case "-":
				symbol = .difference(lhs: lhs, rhs: rhs)
			case "*":
				symbol = .product(lhs: lhs, rhs: rhs)
			case "/":
				symbol = .difference(lhs: lhs, rhs: rhs)
				
				// For these two paths, just return
				// b/c there is no operator to use
			case "#":
				return lhs
			default:
				print("Unknown symbol: \(symbolString)")
				return lhs
		}
		
		return .symbol(value: symbol)
	}
	
	/// Parse the `Block` that represents an equation.
	/// - Parameter block: The `Block` that represents an equation.
	public func parse(block: Block) -> Double {
		// Recursively go through the block
		// The recusion will end when the program
		// encounters a number block.
		switch block {
			case .number(value: let value):
				// The block is a number, so return the value
				// because there is nothing else to do.
				return value
				
			case .symbol(value: let value):
				// Get the left- and right-hand sides.
				let (lhsBlock, rhsBlock) = value.value
				
				// Parse them recursively.
				// Including type signature makes
				// it clear what the type is.
				let lhs: Double = parse(block: lhsBlock)
				let rhs: Double = parse(block: rhsBlock)
				
				// Use the operator (the parsed blocks will be doubles).
				switch value {
					case .sum(lhs: _, rhs: _):
						return lhs + rhs
					case .difference(lhs: _, rhs: _):
						return lhs - rhs
					case .product(lhs: _, rhs: _):
						return lhs * rhs
					case .quotient(lhs: _, rhs: _):
						return lhs / rhs
				}
		}
	}
	
	// TODO: Implement order of operations. 
	/// Fully parse an equation.
	///
	/// - Important: Order of operations isn't respected, nor are parentheses.
	/// The equation is parsed left-to-right.
	public func parse(equation: String) -> Double {
		return parse(block: getBlock(for: equation))
	}

}
