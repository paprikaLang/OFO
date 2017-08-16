//
//  ViewController.swift
//  OFO
//
//  Created by paprika on 2017/8/17.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "Login_Logo"))
        self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_center_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "gift_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem? = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

