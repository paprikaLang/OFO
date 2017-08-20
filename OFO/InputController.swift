//
//  InputController.swift
//  OFO
//
//  Created by paprika on 2017/8/20.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
import APNumberPad
class InputController: UIViewController {

    @IBOutlet weak var goBtn: UIButton!

    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var torchBtn: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    var isVoiceOn = true
    var isTorchOn = false
    @IBAction func torch(_ sender: Any) {
        isTorchOn  = !isTorchOn
        if isTorchOn {
            torchBtn.setImage(#imageLiteral(resourceName: "btn_enableTorch_w"), for: .normal)
        }else{
            torchBtn.setImage(#imageLiteral(resourceName: "btn_enableTorch"), for: .normal)
        }
    }
    
    @IBAction func voice(_ sender: Any) {
        isVoiceOn = !isVoiceOn
        if isVoiceOn {
            voiceBtn.setImage(#imageLiteral(resourceName: "voice_icon"), for: .normal)
        }else
        {
            voiceBtn.setImage(#imageLiteral(resourceName: "voice_close"), for: .normal)
        }
    }
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//      inputTextField.layer.borderWidth = 2
//      inputTextField.layer.borderColor = UIColor.ofo.cgColor
        inputTextField.delegate = self
        let numPad = APNumberPad(delegate: self)
        numPad.leftFunctionButton.setTitle("确定", for: .normal)
        inputTextField.inputView = numPad
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCode" {
            let destVC = segue.destination as! ShowCodeController
            let code = inputTextField.text 
            destVC.code = code
            Network.getPass(code: code!, completion: { (pass) in
                guard let pass = pass
                else{
                    return
                }
                destVC.passArray = pass.characters.map{
                    return $0.description
                }
            })
            
        }
    }

  
}
extension InputController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newLenth = text.characters.count + string.characters.count - range.length
        if newLenth > 0 {
            goBtn.setImage(#imageLiteral(resourceName: "nextArrow_enable"), for: .normal)
            goBtn.backgroundColor = UIColor.ofo
        }else{
            goBtn.setImage(#imageLiteral(resourceName: "nextArrow_unenable"), for: .normal)
            goBtn.backgroundColor = UIColor.groupTableViewBackground
        }
        return newLenth <= 8
    }
}
//MARK:APNumberPad代理方法
extension InputController:APNumberPadDelegate{
    func numberPad(_ numberPad: APNumberPad, functionButtonAction functionButton: UIButton, textInput: UIResponder) {
        if !(inputTextField?.text?.isEmpty)!{
           
            performSegue(withIdentifier: "showCode", sender: self)
        }
    }
}
