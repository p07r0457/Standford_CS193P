//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kyle Maher on 12/23/16.
//  Copyright © 2016 Kyle Maher. All rights reserved.
//

import Foundation

class CalculatorBrain {
	
	private var operations: Dictionary<String, Operation> = [
		"π" : Operation.Constant(M_PI),
		"e" : Operation.Constant(M_E),
		"√" : Operation.UnaryOperation(sqrt),
		"x²" : Operation.UnaryOperation({ $0*$0 }),
		"x³" : Operation.UnaryOperation({ $0*$0*$0 }),
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
	
	private enum Operation {
		case Constant(Double)
		case UnaryOperation((Double) -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case Equals
	}
	
	private var accumulator = 0.0
	
	func clear() {
		accumulator = 0.0
		pending = nil
	}
	
	func setOperand(operand: Double) {
		accumulator = operand
	}
	
	func performOperation(_ symbol: String) {
		if let operation = operations[symbol] {
			switch operation {
			case .Constant(let value):
				accumulator = value
			case .UnaryOperation(let function):
				accumulator = function(accumulator)
			case .BinaryOperation(let function):
				executePendingBinaryOperation()
				pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
			case .Equals:
				executePendingBinaryOperation()
			}
		}
	}
	
	private func executePendingBinaryOperation() {
		if pending != nil {
			accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
			pending = nil
		}
	}
	
	private var pending: PendingBinaryOperationInfo?
	
	private struct PendingBinaryOperationInfo {
		var binaryFunction: (Double, Double) -> Double
		var firstOperand: Double
	}
	
	var result: Double {
		get {
			return accumulator
		}
	}
	
}
