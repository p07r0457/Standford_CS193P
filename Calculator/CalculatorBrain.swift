//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kyle Maher on 12/23/16.
//  Copyright © 2016 Kyle Maher. All rights reserved.
//

import Foundation

/// The brain of the calculator.
class CalculatorBrain {
	
	/// Defines the operations that may be performed by this brain.
	private var operations: Dictionary<String, Operation> = [
		"π" : Operation.Constant(M_PI),
		"e" : Operation.Constant(M_E),
		"RAND" : Operation.Function(drand48),
		"√" : Operation.UnaryOperation(sqrt),
		"x²" : Operation.UnaryOperation({ $0 * $0 }),
		"x³" : Operation.UnaryOperation({ $0 * $0 * $0 }),
		"sin" : Operation.UnaryOperation(sin),
		"cos" : Operation.UnaryOperation(cos),
		"tan" : Operation.UnaryOperation(tan),
		"±" : Operation.UnaryOperation({ -$0 }),
		"×" : Operation.BinaryOperation({ $0 * $1 }),
		"÷" : Operation.BinaryOperation({ $0 / $1 }),
		"+" : Operation.BinaryOperation({ $0 + $1 }),
		"−" : Operation.BinaryOperation({ $0 - $1 }),
		"=" : Operation.Equals
	]
	
	/// Defines the types of operations that may be performed by this brain.
	private enum Operation {
		case Constant(Double)
		case Function(() -> Double)
		case UnaryOperation((Double) -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case Equals
	}
	
	/// Define the data structure for pending binary operation information.
	///
	/// - binaryFunction is the function to evaluate
	/// - firstOperand is the first operand for the operation
	private struct PendingBinaryOperationInfo {
		var binaryFunction: (Double, Double) -> Double
		var firstOperand: Double
	}
	
	/// The current value used for computations.
	private var accumulator: Double = 0
	
	/// The last operation to be performed.
	private var lastOperand: Double?
	
	/// Was the last action performed a Binary Operation?.
	private var isLastActionABinaryOperation = false
	
	/// The current operation being worked on.
	private var currentOperandSegment = String()
	
	/// A history of operations performed.
	private var equationHistory = String()
	
	/// Store pending binary operation information.
	private var pending: PendingBinaryOperationInfo?
	
	/// The result is "partial" if there is a pending operation that has not been performed.
	var isPartialResult: Bool {
		get {
			return pending != nil
		}
	}
	
	/// The history of the calculation.
	var history: String {
		get {
			return equationHistory + currentOperandSegment
		}
	}
	
	/// The result of the calculation.
	var result: Double {
		get {
			return accumulator
		}
	}
	
	/// Format a Double? for display on the screen.
	///
	/// A maximum of 6 digits will be displayed.
	/// Numbers exceeding 6 digits will be rounded, with values 0-4 rounded down, and 5+ rounded up.
	///
	/// - parameter value: Value to be formatted
	func formatForDisplay(_ value: Double?) -> String! {
		if value == nil { return nil }
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.roundingMode = .halfUp
		formatter.maximumFractionDigits = 6
		return formatter.string(from: NSNumber(value: value!))!
	}
	
	/// Clear the accumulator, history, and any pending operation(s).
	func clear() {
		accumulator = 0
		pending = nil
		equationHistory = String()
		currentOperandSegment = String()
	}
	
	/// Set the operand.
	/// - Parameter operand: The operand to set.
	func setOperand(operand: Double) {
		lastOperand = operand
		accumulator = operand
		
		if pending == nil { equationHistory = String() }
		
		currentOperandSegment = formatForDisplay(operand)
	}
	
	/// Perform a mathematical operation.
	/// - Parameter symbol: The mathematical symbol of the operation being performed.
	func performOperation(_ symbol: String) {
		if let operation = operations[symbol] {
			let wasLastActionABinaryOperation = isLastActionABinaryOperation
			isLastActionABinaryOperation = false
			
			switch operation {
			case .Constant(let value):
				accumulator = value
				currentOperandSegment = symbol
				
			case .Function(let function):
				accumulator = function()
				currentOperandSegment = formatForDisplay(accumulator)
				
			case .UnaryOperation(let function):
				accumulator = function(accumulator)
				
				if (currentOperandSegment.characters.count > 0) {
					equationHistory += symbol + "(" + currentOperandSegment + ")"
				}
				else {
					equationHistory = symbol + "(" + equationHistory + ")"
				}
				
				currentOperandSegment = String()
				
			case .BinaryOperation(let function):
				executePendingBinaryOperation()
				pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
				currentOperandSegment += symbol
				isLastActionABinaryOperation = true
				
			case .Equals:
				executePendingBinaryOperation()
				if wasLastActionABinaryOperation { currentOperandSegment = formatForDisplay(lastOperand) }
			}
			
			equationHistory += currentOperandSegment
			currentOperandSegment = String()
		}
	}
	
	/// Execute a pending binary operation.
	private func executePendingBinaryOperation() {
		if pending != nil {
			accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
			pending = nil
		}
	}
	
}
