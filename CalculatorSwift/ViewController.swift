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
    
//  var operandStack = Array<Double>()
    var brain = CalculatorBrain()
    var displayValue :Double? {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if newValue != nil {
                display.text = "\(newValue!)"
            } else
            {
                display.text = "0"
            }
            
            userIsInTheMiddleOfTypingANumber = false
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
            history.text = brain.description
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
            history.text = brain.description
        }
    }

    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false

//        operandStack.append(displayValue)
//        println("OperandStack: \(operandStack)")
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
        } else {
            // making displayValue an optional
            // put an error message in the display - extra credit
            displayValue = 0
        }
        history.text = brain.description
    }
    
    
    @IBAction func clear() {
//       displayValue = 0
        display.text = "0"
//        operandStack.removeAll(keepCapacity: false)
        brain.performClear()
        
        userIsInTheMiddleOfTypingANumber = false
        history.text = brain.description
    }
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        let operation = sender.currentTitle!
        brain.performOperation(operation)
        
        if let result = brain.evaluate(){
            displayValue = result
        } else {
            displayValue = 0
        }
        history.text = brain.description
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

