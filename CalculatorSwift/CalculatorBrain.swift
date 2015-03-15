//
//  CalculatorBrain.swift
//  CalculatorSwift
//
//  Created by DAVID VELA TIRADO on 13/03/15.
//  david.vela.tirado@gmail.com
//  Copyright (c) 2015 DAVID VELA TIRADO. All rights reserved.
//

import Foundation

class CalculatorBrain{

    // assoicate data with any of the cases of enum
    private enum Op: Printable //PROTOCOL
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double )
        case BinaryOperation(String, (Double,Double) -> Double )
        case ConstantOperation(String, Double)
        case Variables(String)

        var description: String{ //COMPUTER PROPERTY
            get{
                switch self{
                case .Operand(let operand): return "\(operand)"
                case .UnaryOperation(let symbol,_):  return symbol
                case .BinaryOperation(let symbol,_): return symbol
                case .ConstantOperation(let symbol, _): return symbol
                case .Variables(let symbol): return symbol

                }
            }
//            set{ // ONLY READ ONLY
//            }
        }

    }
    private var opStack = [Op]()
    private var knownOps = Dictionary<String, Op>() //[String:Op]() key, value // public? first private
    
    var variableValues = Dictionary<String,Double>()

    
    init(){ //initialator
        
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×",*)) //{ $0 * $1 } //ONLY ONE TIME THE DESCRIPTION
        knownOps["÷"] = Op.BinaryOperation("÷"){ $1 / $0 } //order backwards
        knownOps["−"] = Op.BinaryOperation("−"){ $1 - $0 }
        knownOps["+"] = Op.BinaryOperation("+",+)//{ $0 + $1 }
        knownOps["√"] = Op.UnaryOperation ("√", sqrt) //{ sqrt($0) }
        
        learnOp(Op.UnaryOperation("sin",sin))
        learnOp(Op.UnaryOperation ("sin", sin))
        learnOp(Op.UnaryOperation ("cos", cos))
        learnOp(Op.UnaryOperation ("tan", tan))
        learnOp(Op.UnaryOperation ("+/-", -))
        learnOp(Op.ConstantOperation("π", M_PI))
        learnOp(Op.Variables("M"))
    }
    
    var description: String {
        get{
//            let(result, remainder) = evaluateAndReportErrors(opStack)
//            return result!
            return ("\(opStack)")
        }
        
    }
    
    private func evaluateAndReportErrors(ops: [Op])->(result: String?, remainingOps: [Op])
    {
        var remainingOps = ops
        if !ops.isEmpty{
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .UnaryOperation(let operation, _ ):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return("\(operation) \(operand)",operandEvaluation.remainingOps)
                }
//            case .BinaryOperation(_,  let operation):
//                let op1Evaluation = evaluate(remainingOps)
//                if let operand1 = op1Evaluation.result{
//                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
//                    if let operand2 = op2Evaluation.result {
//                        return (operation(operand1, operand2),op2Evaluation.remainingOps)
//                    }
//                }
//            case .ConstantOperation( let symbol , let value ):
//                return(value, remainingOps,)
//                
//            case .Variables( let symbol ):
//                return(variableValues[symbol] , remainingOps)
            default: break
            }
        }
        return (nil, ops)
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
            case .UnaryOperation(_, let operation ):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return(operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_,  let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2),op2Evaluation.remainingOps)
                    }
                }
            case .ConstantOperation( _ , let value ):
                return(value, remainingOps)
            case .Variables( let symbol ):
                return(variableValues[symbol] , remainingOps)
            }
        }
        return (nil, ops)
    }
    
    
    
    func evaluate() -> Double?{
        let(result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over ")
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
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
    
    func undo(){
        opStack.removeLast()
    }

}