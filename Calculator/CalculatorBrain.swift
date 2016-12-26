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
	private var equationHistory = String()
	private var lastOperand: Double?
	private var currentOperandSegment = String()
	private var isLastActionABinaryOperation = false
	
	func clear() {
		accumulator = 0.0
		pending = nil
		equationHistory = String()
		currentOperandSegment = String()
	}
	
	func setOperand(operand: Double) {
		lastOperand = operand
		accumulator = operand
		
		if pending == nil { equationHistory = String() }
		
		currentOperandSegment = String(operand)
	}
	
	func performOperation(_ symbol: String) {
		if let operation = operations[symbol] {
			let wasLastActionABinaryOperation = isLastActionABinaryOperation
			isLastActionABinaryOperation = false
			
			switch operation {
			case .Constant(let value):
				accumulator = value
				currentOperandSegment = symbol
				
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
				if wasLastActionABinaryOperation { currentOperandSegment = String(lastOperand!) }
			}
			
			equationHistory += currentOperandSegment
			currentOperandSegment = String()
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
	
	var isPartialResult: Bool {
		get {
			return pending != nil
		}
	}
	
	var history: String {
		get {
			return equationHistory + currentOperandSegment
		}
	}
	
	var result: Double {
		get {
			return accumulator
		}
	}
	
}
