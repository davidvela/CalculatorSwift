//
//  ViewController.swift
//  CalculatorSwift
//
//  Created by DAVID VELA TIRADO on 12/03/15.
//  david.vela.tirado@gmail.com
//  Copyright (c) 2015 DAVID VELA TIRADO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    var displayValue :Double? {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                let result = brain.evaluateAndReportErrors()
                display.text = "\(result!)"
            }
            userIsInTheMiddleOfTypingANumber = false
//            history.text = brain.description != "" ? "= " + brain.description : ""
            history.text = "= \(brain)"
        }
    }
    
    //METHODS
    @IBAction func appendDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        let isFloating = digit == "."
        let isPI = digit == "π"

        if userIsInTheMiddleOfTypingANumber {
            let userHasAFloatingPoint = display.text!.rangeOfString(".") != nil
            if isFloating && userHasAFloatingPoint{
                return
            }
            
            display.text = display.text! + digit
        
        } else {
            userIsInTheMiddleOfTypingANumber = true
            
            if isFloating
            {
                display.text = "0."
            
            } else
            {
                display.text = digit
            }
        }
        
    }
 
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            if countElements(display.text!) > 1 {
              display.text = dropLast(display.text!)
            } else {
                displayValue = nil
            }
        } else {
            brain.undo()
            displayValue = 0
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            
            if display.text!.rangeOfString("-") != nil
            {
                display.text = dropFirst(display.text!)
            } else {
                display.text = "-" + display.text!
            }
            
        } else {
            operate(sender)
        }
    }

    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    
    @IBAction func StoreVariable(sender: UIButton) {
        
        if let variable = last(sender.currentTitle!) {
            if displayValue != nil {
                brain.variableValues["\(variable)"] = displayValue
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    
    @IBAction func clear() {
        display.text = "0"
        brain.performClear()
        brain.variableValues.removeAll(keepCapacity: false)
        userIsInTheMiddleOfTypingANumber = false
        history.text = " "
    }
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        let operation = sender.currentTitle!
        brain.performOperation(operation)
        displayValue = brain.evaluate()
    }
} //end


//CODE IN THE MODEL 
// print the stack
//        switch operation{
//        case "×" : performOperation { $0 * $1 }
//        case "÷" : performOperation { $1 / $0 }
//        case "−" : performOperation { $0 - $1 }
//        case "+" : performOperation { $0 + $1 }
//        case "√" : performOperation { sqrt($0) }
//        default : break
//        }
//    }
//    func performOperation ( operation: (Double, Double) -> Double)
//    {
//        if operandStack.count >= 2 {
//            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
//            enter()
//        }
//    }
//    
//    
//    func performOperation ( operation: (Double) -> Double)
//    {
//        if operandStack.count >= 1 {
//            displayValue = operation(operandStack.removeLast())
//            enter()
//        }
//    }
//}

