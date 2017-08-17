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
    
    @IBOutlet weak var toolbarView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var mapView = MAMapView(frame: UIScreen.main.bounds)

  
    
    @IBAction func LocationBtnTap(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        mapView.delegate = self as MAMapViewDelegate
        setupMapSystem()
        view.insertSubview(mapView, belowSubview: toolbarView)
    }

}
//MARK:高德地图代理
extension ViewController:MAMapViewDelegate{
   fileprivate func setupMapSystem(){
        //地图一打开的精度越大越精准
        mapView.zoomLevel = 15
        //一直追踪定位
        mapView.userTrackingMode = .follow
        //先定位在追踪,否则不显示蓝点.(注意顺序)
        mapView.showsUserLocation = true
    }
    
}

//MARK:UI布局
extension ViewController{
    
   fileprivate func setupUI(){
        //转换方向
        imageView.image = #imageLiteral(resourceName: "whiteImage").rotate(UIImageOrientation(rawValue: 5)!)
        setupNavi()
        setupRevealVC()
    }
   fileprivate func setupNavi()  {
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "Login_Logo"))
        self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_center_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "gift_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem? = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
   fileprivate func setupRevealVC(){
        if let revealVC = revealViewController() {
            revealVC.rearViewRevealWidth = 280
            self.navigationItem.leftBarButtonItem?.target = revealVC
            self.navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }

    }
}











