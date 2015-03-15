//
//  CalculatorBrain.swift
//  CalculatorSwift
//
//  Created by DAVID VELA TIRADO on 13/03/15.
//  david.vela.tirado@gmail.com
//  Copyright (c) 2015 DAVID VELA TIRADO. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable{

    // assoicate data with any of the cases of enum
    private enum Op: Printable //PROTOCOL
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double , ((Double) -> String?)?)
        case BinaryOperation(String, Int, (Double,Double) -> Double, ((Double, Double) -> String?)? )
        case ConstantOperation(String, Double)
        case Variables(String)

        var description: String{ //COMPUTER PROPERTY
            get{
                switch self{
                case .Operand(let operand): return "\(operand)"
                case .UnaryOperation(let symbol,_, _):  return symbol
                case .BinaryOperation(let symbol,_,_, _): return symbol
                case .ConstantOperation(let symbol, _): return symbol
                case .Variables(let symbol): return symbol

                }
            }
        }
        var precedence: Int {
            get{
                switch self{
                case .BinaryOperation(_, let precedence, _, _): return precedence
                default: return Int.max
                }
            }
        
        }

    }
    private var opStack = [Op]()
    private var knownOps = Dictionary<String, Op>() //[String:Op]() key, value // public? first private
    
    var variableValues = Dictionary<String,Double>()
    private var error: String?

    
    init(){ //initialator
        
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×",2,*,nil)) //{ $0 * $1 } //ONLY ONE TIME THE DESCRIPTION
        knownOps["÷"] = Op.BinaryOperation("÷",2, { $1 / $0 }, //order backwards
            { divisor, _ in return divisor == 0 ? "divisor by cero" : nil})
        knownOps["−"] = Op.BinaryOperation("−",1,{ $1 - $0 }, nil)
        knownOps["+"] = Op.BinaryOperation("+",1,+, nil)//{ $0 + $1 }
        knownOps["√"] = Op.UnaryOperation ("√", sqrt){ return $0 < 0 ? "SQRT. of negative number " :nil } //{ sqrt($0) }
        
        learnOp(Op.UnaryOperation("sin",sin, nil))
        learnOp(Op.UnaryOperation ("sin", sin, nil))
        learnOp(Op.UnaryOperation ("cos", cos, nil))
        learnOp(Op.UnaryOperation ("tan", tan, nil))
        learnOp(Op.BinaryOperation("%",2, %, nil))
        learnOp(Op.UnaryOperation ("log", log, { return $0 <= 0 ? "LN. of incorrect number " :nil } ))
        learnOp(Op.ConstantOperation("π", M_PI))
        learnOp(Op.ConstantOperation("e", M_E))

    }
    
    var description: String {
        get{
            var(result, ops) = (" ",opStack)
            
            while ops.count > 0 {
                var current: String?
                (current,ops,_) = description(ops)
                if current != nil {
                   
                    result = "\(current!) , \(result)"
                
                }
            }
            
            return result
//          return ("\(opStack)")
        }
        
    }
    
    private func description(ops: [Op])->(result: String?, remainingOps: [Op], precedence: Int?)
    {
        var remainingOps = ops
        if !ops.isEmpty{
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps, op.precedence)
                
            case .UnaryOperation(let operation, _ , _):
                let operandEvaluation =   description(remainingOps)
                if var operand = operandEvaluation.result {
//                    if op.precedence > operandEvaluation.precedence {
//                        operand = "(\(operand))"
//                    }
                    return("\(operation)(\(operand))",operandEvaluation.remainingOps, op.precedence)
                } else {
                    return("\(operation)(?)",operandEvaluation.remainingOps, op.precedence)
                }
                
                
            case .BinaryOperation(let symbol, _, _, _ ):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result{
                    if op.precedence > op1Evaluation.precedence {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)",op2Evaluation.remainingOps, op.precedence)
                    } else {
                    return ("\(operand1) \(symbol) ? ",op2Evaluation.remainingOps, op.precedence)
                
                    }
                } else {
                    return("? \(symbol) ?",op1Evaluation.remainingOps, op.precedence)
                }
                
            case .ConstantOperation( let symbol , _ ):
                return(symbol, remainingOps, op.precedence)
                
            case .Variables( let symbol ):
                return(symbol , remainingOps, op.precedence)
            default: break
            }
        }
        return (nil, ops,Int.max)
    }
    
    
    // by default elements public in your program (no specificaton); private - private
    // public only when you have a framework and you want elements to be public outside the framework
    //set and getter ... more objectiveC, in swift not. Only private or public
    // make everything private - private
    //Recursion...
    
    private func evaluate(ops: [Op])->(result: Double?, remainingOps: [Op])
    {
        var remainingOps = ops
        if !ops.isEmpty{
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation, let errorTest ):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    if let errorMessage = errorTest?(operand){
                        error = errorMessage
                        return (nil, operandEvaluation.remainingOps)
                    }
                    return(operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation, let errorTest):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        
                        if let errorMessage = errorTest?(operand1, operand2){
                            error = errorMessage
                            return (nil,op2Evaluation.remainingOps)

                        }
                        return (operation(operand1, operand2),op2Evaluation.remainingOps)
                    }
                }
            case .ConstantOperation( _ , let value ):
                return(value, remainingOps)
            case .Variables( let symbol ):
                if let variable = variableValues[symbol] {
                    return(variable , remainingOps)
                }
                error = "Variable Not Set"
                return (nil, remainingOps)
            }
            
            if error == nil {
                error = "Not Enough Operands"
                return (nil, remainingOps)
            }
        }
        return (nil, ops)
    }
    
    
    
    func evaluate() -> Double?{
        error = nil
        let(result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over ")
        return result
    }
    
    func evaluateAndReportErrors() -> String? {
        error = nil
        let (result, _) = evaluate(opStack)
        println("result= \(result) and error = \(error)")
        return error != nil ? error! : "0"
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variables(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String){
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
    
    func performClear(){
        opStack.removeAll(keepCapacity: false)

    }
    
    func undo()->Double?{
        opStack.removeLast()
        return evaluate()
    }

}