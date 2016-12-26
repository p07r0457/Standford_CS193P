//
//  ViewController.swift
//  Calculator
//
//  Created by Kyle Maher on 12/22/16.
//  Copyright © 2016 Kyle Maher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private var brain = CalculatorBrain()
	
	let defaultDisplayValue = "0"
	
	private var userIsInMiddleOfTyping = false
	
	private var displayValue: Double? {
		get {
			return Double(display.text!)
		}
		set {
			if newValue != nil {
				display.text = String(newValue!)
			}
			else {
				display.text = defaultDisplayValue
			}
		}
	}
	
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
	
	@IBOutlet private weak var display: UILabel!
	@IBOutlet weak var history: UILabel!
	
	@IBAction func clear(_ sender: UIButton) {
		print("Clear pressed.")
		
		brain.clear()
		
		displayValue = 0
		historyValue = String()
	}
	
	@IBAction func backspace(_ sender: UIButton) {
		var value = display.text!
		
		let index = value.index(value.startIndex, offsetBy: value.characters.count - 1)
		value = value.substring(to: index)
		
		if value.characters.count == 0 { value = defaultDisplayValue }
		display.text = value
	}
	
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
