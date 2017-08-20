//
//  View+Extension.swift
//  OFO
//
//  Created by paprika on 2017/8/20.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
extension UIView{
    //在SB的属性栏有显示的修饰符
   @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
   @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }

    }
    
   @IBInspectable var cornerRaidius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }
}

@IBDesignable class MyPreviewLabel:UILabel{
    
}

import AVFoundation

func turnTorch(){
    guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
        return
    }
    if device.hasTorch && device.isTorchActive {
        try? device.lockForConfiguration()
        
        if device.torchMode == .off {
            device.torchMode = .on
        } else {
            device.torchMode = .off
        }
        device.unlockForConfiguration()
    }
}























