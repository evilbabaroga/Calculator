//
//  ViewController.swift
//  Calculator
//
//  Created by Kiko on 3/20/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnDiv: UIButton!
    @IBOutlet weak var btnMul: UIButton!
    @IBOutlet weak var btnSub: UIButton!
    @IBOutlet weak var btnOne: UIButton!
    @IBOutlet weak var btnTwo: UIButton!
    @IBOutlet weak var btnThree: UIButton!
    @IBOutlet weak var btnFour: UIButton!
    @IBOutlet weak var btnFive: UIButton!
    @IBOutlet weak var btnSix: UIButton!
    @IBOutlet weak var btnSeven: UIButton!
    @IBOutlet weak var btnEight: UIButton!
    @IBOutlet weak var btnNine: UIButton!
    @IBOutlet weak var btnZero: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnEquals: UIButton!
    
    var expression = String()
    var currentOperator = String()
    var buttonClicked = Bool()
    var infix = [String()]
    var evaluated = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expression = ""
        currentOperator = ""
        buttonClicked = false
        evaluated = false
        infix = []
    }
    
    class Stack {
        var stackArray = [String]()
        
        func push(toPush : String) {
            self.stackArray.append(toPush)
        }
        
        func pop() -> String? {
            if self.stackArray.last != nil{
                let toReturn = self.stackArray.last
                self.stackArray.removeLast()
                return toReturn!
            } else {
                return nil
            }
        }
        
        func peek() -> String{
            return stackArray[stackArray.count - 1]
        }
        
        public func isEmpty() -> Bool{
            if stackArray.count == 0{
                return true
            }
            return false
        }
        
        public var description: String {
            var toPrint = String()
            for s in stackArray{
                toPrint += s
            }
            return toPrint
        }
    }

    @IBAction func pressedClear(_ sender: Any) {
        clear()
        updateText()
    }
    
    func clear(){
        expression = ""
        currentOperator = ""
        buttonClicked = false
        evaluated = false
        infix = []
    }
    
    func updateText(){
        txtField.text = expression
    }
    
    func isOperator(op : String) -> Bool{
        if op == "-" || op == "=" || op == "+" || op == "×" || op == "÷"{
            return true
        }
        return false
    }
    
    func precedence(op: String) -> Int{
        if op == "÷" || op == "×"{
            return 2
        }
        if op == "+" || op == "-"{
            return 1
        }
        return -1
    }
    
    
    func evaluate(terms : [String]) -> Float {
        let postfix = toPostfix(terms: infix)
        let stack = Stack()
        var operand1 = Float()
        var operand2 = Float()
        
        for term in postfix{
            if !isOperator(op: term){
                stack.push(toPush: term)
            } else {
                operand2 = Float(stack.pop()!)!
                operand1 = Float(stack.pop()!)!
                switch term {
                case "+":
                    stack.push(toPush: String(operand1 + operand2))
                case "-":
                    stack.push(toPush: String(operand1 - operand2))
                case "×":
                    stack.push(toPush: String(operand1 * operand2))
                case "÷":
                    if operand2 == 0{
                        pressedClear((Any).self)
                        return 0
                    } else {
                        stack.push(toPush: String(operand1 / operand2))
                    }
                default:
                    stack.push(toPush: "0")
                }
            }
        }
        
        return Float(stack.pop()!)!
    }
    
    func toPostfix(terms : [String]) -> [String]{
        let operators = Stack()
        var postfix = [String]()
        
        for term in terms{
            let temp1 = Int(term) ?? 1
            let temp2 = Int(term) ?? 2
            if temp1 != temp2{ // Not an Int
                let temp1 = Float(term) ?? 1
                let temp2 = Float(term) ?? 2
                if temp1 != temp2{ // Not a Float
                    while (!operators.isEmpty() && ((precedence(op: operators.peek()) >= precedence(op: term)))){
                        postfix.append(operators.pop()!)
                    }
                    operators.push(toPush: term)
                    continue
                }
            }
            postfix.append(term)
        }
        while (!operators.isEmpty()){
            postfix.append(operators.pop()!)
        }
        print(postfix)
        
        return postfix
    }
    
    @IBAction func pressedNum(_ sender: Any) {
        if let touchedButton : UIButton = sender as? UIButton {
            if (evaluated){
                return
            }
            let val = touchedButton.tag
            if !(infix.count >= 1 && infix[infix.count - 1] == "0" && val == 0){
                expression += String(val)
            }
            buttonClicked = false
            updateText()
            if (!buttonClicked && !isOperator(op: infix.last ?? "+")) {
                let temp : Int? = Int(infix.last ?? "0")
                print(String(temp!) + " " + infix.last!)
                let newVal = (temp ?? 0) * 10 + val
                print(newVal, infix, infix.count)
                infix[infix.count - 1] = String(newVal)
                print(infix, infix.count)
            } else {
                infix.append(String(val))
                print(infix)
            }
        } else {
            print("No button found")
        }
        
    }
    
    @IBAction func pressedOperator(_ sender: Any){
        if let touchedButton : UIButton = sender as? UIButton{
            if (buttonClicked || expression == ""){
                return
            }
            if (evaluated){
                evaluated = false
            }
            let operatorType = touchedButton.titleLabel?.text
            buttonClicked = true
            expression += operatorType ?? ""
            updateText()
            
            infix.append(String(operatorType ?? ""))
        } else {
            print("No button found")
        }
        
    }
    
    @IBAction func pressedEquals(_ sender: Any) {
        if (buttonClicked || expression == ""){
            return
        }
        if infix.count == 1{
            updateText()
            return
        }
        print(infix)
        expression += "="
        let result = evaluate(terms: infix)
        infix = [String(result)]
        var toWrite = ""
        if result.rounded() - result == 0{
            toWrite = String(Int(result.rounded()))
        } else {
            toWrite = String(result)
        }
        expression += toWrite
        evaluated = true
        updateText()
        expression = toWrite
    }
}
