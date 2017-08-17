//
//  MenuTableViewController.swift
//  OFO
//
//  Created by paprika on 2017/8/17.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
//**注意:UITableViewController的代理方法应该省略,否则不会走SB里的tableView视图
class MenuTableViewController: UITableViewController {

    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var certView: UIImageView!
    
    @IBOutlet weak var certLabel: UILabel!
    
    @IBOutlet weak var creditLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

// MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

   
}
