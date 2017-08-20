//
//  ScanController.swift
//  OFO
//
//  Created by paprika on 2017/8/18.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
import swiftScan
import FTIndicator
class ScanController: LBXScanViewController {

    var isFlashOn:Bool = false
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var torchBtn: UIButton!
    @IBOutlet weak var panelView: UIView!
    
    @IBAction func flashOn(_ sender: Any) {
        isFlashOn = !isFlashOn
        scanObj?.changeTorch()
        if isFlashOn {
            torchBtn.setImage(#imageLiteral(resourceName: "btn_enableTorch_w"), for: .normal)
        }else{
            torchBtn.setImage(#imageLiteral(resourceName: "btn_torch_disable"), for: .normal)
        }
        
    }
    //处理扫描之后的结果
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
         let result = arrayResult[0]
         let str = result.strScanned
         FTIndicator.setIndicatorStyle(.dark)
         FTIndicator.showToastMessage(str)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "扫码用车"
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = UIColor.white
        var style = LBXScanViewStyle()
        style.anmiationStyle = .LineMove
        style.animationImage = #imageLiteral(resourceName: "bg_QRCodeLine")
        style.colorRetangleLine = UIColor.yellow
        style.colorAngle = UIColor.yellow
        scanStyle = style
        tipLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.bringSubview(toFront: panelView)
        tipLabel.isHidden = false
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
