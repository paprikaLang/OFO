//
//  ViewController.swift
//  OFO
//
//  Created by paprika on 2017/8/17.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
import SWRevealViewController

class ViewController: UIViewController {

    @IBOutlet weak var toolbarView: UIImageView!
    
    @IBAction func LocationBtnTap(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "Login_Logo"))
        self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_center_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "gift_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem? = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let revealVC = revealViewController() {
            revealVC.rearViewRevealWidth = 280
            self.navigationItem.leftBarButtonItem?.target = revealVC
            self.navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        toolbarView.image = #imageLiteral(resourceName: "whiteImage").rotate(UIImageOrientation(rawValue: 5)!)
        
        
    }

    /*
     public enum UIImageOrientation : Int {
     
     
     case up // default orientation
     
     case down // 180 deg rotation
     
     case left // 90 deg CCW
     
     case right // 90 deg CW
     
     case upMirrored // as above but image mirrored along other axis. horizontal flip
     
     case downMirrored // horizontal flip
     
     case leftMirrored // vertical flip
     
     case rightMirrored // vertical flip
     }
     
     
     
     */
}

