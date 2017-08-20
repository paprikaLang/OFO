//
//  ShowCodeController.swift
//  OFO
//
//  Created by paprika on 2017/8/20.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
import SwiftyTimer
import SwiftySound
class ShowCodeController: UIViewController {
    var code :String!
    var passArray = [String](){
        //属性将要改变的时候
        willSet{
            
        }
        //当属性在外界已经改变的时候,如何处理
        didSet{
            self.pass1st.text = passArray[0]
            self.pass2nd.text = passArray[1]
            self.pass3rd.text = passArray[2]
            self.pass4th.text = passArray[3]
        }
    }
    var counts = 120
    var isTorchOn = false
    var isVoiceOn = true
    
    
    
    @IBOutlet weak var pass1st: MyPreviewLabel!
    
    @IBOutlet weak var pass2nd: UILabel!
    
    @IBOutlet weak var pass3rd: UILabel!
    
    @IBOutlet weak var pass4th: UILabel!
    
    
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var voiceBtn: UIButton!
    
    @IBOutlet weak var torchBtn: UIButton!
    
    
    @IBAction func torch(_ sender: Any) {
        turnTorch()
        if isTorchOn {
            torchBtn.setImage(#imageLiteral(resourceName: "btn_enableTorch_w"), for: .normal)
        } else {
            torchBtn.setImage(#imageLiteral(resourceName: "btn_enableTorch"), for: .normal)
        }
        isTorchOn = !isTorchOn
    }
    

    @IBAction func voice(_ sender: Any) {
        isVoiceOn = !isVoiceOn
        if isVoiceOn {
            voiceBtn.setImage(#imageLiteral(resourceName: "voice_icon"), for: .normal)
            
        } else {
            voiceBtn.setImage(#imageLiteral(resourceName: "voice_close"), for: .normal)
            Sound.stopAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.every(1) { (timer:Timer) in
            self.counts -= 1
            self.countDownLabel.text = self.counts.description
            if self.counts == 0{
                timer.invalidate()
            }
        }
      Sound.play(file: "骑行结束_LH.m4a")
    }

    @IBAction func fixBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
   
}
