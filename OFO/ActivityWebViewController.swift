//
//  ActivityWebViewController.swift
//  OFO
//
//  Created by paprika on 2017/8/17.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit

class ActivityWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = "热门活动"
        guard let url = URL(string: "http://m.ofo.so/active.html")else{
            return
        }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        
    }

    fileprivate func setupUI(){
        webView.scrollView.contentInset.top = CGFloat(-64)
        webView.backgroundColor = UIColor.white
        webView.scrollView.bounces = false
        //在xib里调整scales page to fit(适配布局)
        
    }
 
    
    

}
