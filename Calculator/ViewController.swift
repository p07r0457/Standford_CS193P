//
//  ViewController.swift
//  Calculator
//
//  Created by Kyle Maher on 12/22/16.
//  Copyright © 2016 Kyle Maher. All rights reserved.
//

import UIKit

/// View Controller for main calculator Ui.
class ViewController: UIViewController {
	
	/// The default display value.
	let defaultDisplayValue = "0"
	
	/// Outlet for display label on Ui
	@IBOutlet private weak var display: UILabel!
	
	/// Outlet for history label on Ui
	@IBOutlet weak var history: UILabel!
	
	/// The calculator brain instance.
	private var brain = CalculatorBrain()
	
	/// Is the user in the middle of typing a value?
	private var userIsInMiddleOfTyping = false
	
	/// The display value.
	///
	/// When getting, the display text is cast to a Double and returned.
	///
	/// When setting, a Double is formatted and then displayed on the Ui.
	private var displayValue: Double? {
		get {
			return Double(display.text!)
		}
		set {
			if newValue != nil {
				display.text = brain.formatForDisplay(newValue)
			}
			else {
				display.text = defaultDisplayValue
			}
		}
	}
	
	/// The history of the calculation.
	///
	/// When getting, the history is returned as a String.
	///
	/// When setting, the history is built and indicators such as "..." and "=" are appended, as appropriate.
	private var historyValue: String {
		get {
			return history.text!
		}
		set {
			var value = newValue
			
			if brain.isPartialResult { value += "..." }
			else if value.characters.count > 0 { value += "=" }
			
			if value.characters.count == 0 { value += " " }
			
			history.text = value
		}
	}
	
	/// Action for the Clear button on the Ui
	///
	/// Resets the calculator as-if a fresh instance was just launched.
	@IBAction func clear(_ sender: UIButton) {
		print("Clear pressed.")
		
		brain.clear()
		
		displayValue = 0
		historyValue = String()
	}
	
	/// Action for the Backspace button on the Ui.
	///
	/// Allows the user to correct mistakes when entering values.
	@IBAction func backspace(_ sender: UIButton) {
		var value = display.text!
		
		let index = value.index(value.startIndex, offsetBy: value.characters.count - 1)
		value = value.substring(to: index)
		
		if value.characters.count == 0 { value = defaultDisplayValue }
		display.text = value
	}
	
	/// Action for a digit button on the Ui.
	///
	/// Updates state when user is in the middle of typing a value and updates the display.
	@IBAction private func touchDigit(_ sender: UIButton) {
		let digit = sender.currentTitle!
		
		print("Digit \(digit) pressed.")
		
		if userIsInMiddleOfTyping {
			let textCurrentlyOnDisplay = display.text!
			
			if digit == "." && textCurrentlyOnDisplay.range(of: ".") != nil {
				return
			}
			
			display.text = textCurrentlyOnDisplay + digit
		} else {
			display.text = digit;
		}
		
		userIsInMiddleOfTyping = true;
	}
	
	/// Action for an operation button on the Ui.
	///
	/// Performs the calculation and updates the display and history labels.
	@IBAction private func performOperation(_ sender: UIButton) {
		let mathematicalSymbol = sender.currentTitle!
		
		print("Operation \(mathematicalSymbol) pressed.")
		
		if (userIsInMiddleOfTyping) {
			brain.setOperand(operand: displayValue!)
			userIsInMiddleOfTyping = false;
		}
		
		brain.performOperation(mathematicalSymbol)
		
		displayValue = brain.result
		historyValue = brain.history
	}
}
