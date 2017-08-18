//
//  ViewController.swift
//  OFO
//
//  Created by paprika on 2017/8/17.
//  Copyright © 2017年 paprika. All rights reserved.
//

import UIKit
import SWRevealViewController
import FTIndicator

class ViewController: UIViewController {
    
    @IBOutlet weak var toolbarView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var pinView : MAAnnotationView!
    var nearBy :Bool! = true
    var start,end :CLLocationCoordinate2D!
    
    lazy var mapView = MAMapView(frame: UIScreen.main.bounds)
    /// '?' must be followed by a call, member lookup, or subscript
    lazy var search :AMapSearchAPI = AMapSearchAPI()
    
    lazy var myPin : MyPinAnnotation = MyPinAnnotation()
    
    lazy var walkManager:AMapNaviWalkManager = AMapNaviWalkManager()
    
    
    
    @IBAction func LocationBtnTap(_ sender: UIButton) {
        nearBy = true
        searchBikeNearby()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        mapView.delegate = self as MAMapViewDelegate
        search.delegate = self as AMapSearchDelegate
        walkManager.delegate = self as AMapNaviWalkManagerDelegate
        setupMapSystem()
        view.insertSubview(mapView, belowSubview: toolbarView)
    }

}

//MARK:导航步行路线规划
extension ViewController:AMapNaviWalkManagerDelegate{
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        print("规划成功")
        mapView.removeOverlays(mapView.overlays)
        var coordinates = walkManager.naviRoute!.routeCoordinates.map{
            return CLLocationCoordinate2D(latitude:CLLocationDegrees( $0.latitude), longitude:CLLocationDegrees($0.longitude))
        }
        let polyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.add(polyline)
        alertAction(routeTime: walkManager.naviRoute!.routeTime, routeLength:walkManager.naviRoute!.routeLength)
    }
    
    func alertAction(routeTime:Int,routeLength:Int){
        let walkTime = routeTime/60
        var timeDes = "一分钟内"
        if walkTime > 0 {
            timeDes = walkTime.description + "分钟"
        }
        let hintTitle = "步行" + timeDes
        let hintSubTitle = "距离" + routeLength.description + "米"
        FTIndicator.setIndicatorStyle(.dark)
        FTIndicator.showNotification(with: #imageLiteral(resourceName: "clock"), title: hintTitle, message: hintSubTitle)
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
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        //如果是用户图标不自定义,返回就行了
        if annotation is MAUserLocation{
            return nil
        }
        if annotation is MyPinAnnotation {
            let reuseId = "myBikeId"
            var myPinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MAPinAnnotationView
            if myPinView == nil {
                myPinView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            myPinView?.canShowCallout = false
            myPinView?.image = #imageLiteral(resourceName: "homePage_wholeAnchor")
            pinView = myPinView
            return myPinView
        }
        let reuseId = "bikeId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MAPinAnnotationView
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        if annotation.title == "可以正常解锁" {
            annotationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBike")
        }else{
            annotationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBikeRedPacket")
            }
        annotationView?.canShowCallout = true
        annotationView?.animatesDrop = true
        return annotationView
    }
    
    //地图初始化成功后
    func mapInitComplete(_ mapView: MAMapView!) {
    
        myPin.coordinate = mapView.centerCoordinate
        myPin.lockedScreenPoint = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        myPin.isLockedToScreen = true
        //小黄车和大头钉一块儿显示
        mapView.addAnnotation(myPin)
        mapView.showAnnotations([myPin], animated: true)
        searchBikeNearby()
    }
    //移动地图的交互
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            
            //中心图标不能更改,否则定位范围不会改变
            myPin.isLockedToScreen = true
            
            //移动之后重新在黑图标附近寻找小黄车
            searchCustomLocation(mapView.centerCoordinate)
            pinAnimator()
//            animator = UIDynamicAnimator(referenceView: view)
//            let snapAnimator = UISnapBehavior(item: pinView, snapTo: view.center)
//            snapAnimator.damping = 1
//            animator.addBehavior(snapAnimator)

        }
    }
    //用户图标动画
    func pinAnimator(){
        
           pinView.frame.origin.y = 10
        
           UIView.animate(withDuration: 1,
                          delay: 0,
                          usingSpringWithDamping: 0.2,
                          initialSpringVelocity: 0,
                          options: [],
                          animations: {
                            
                             self.pinView.frame.origin.y = 0
                            
                          }, completion: nil)
    }
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        let aViews = views as! [MAAnnotationView]
        for aView in aViews {
            
            guard aView.annotation is MAPointAnnotation else {
                continue
            }
            aView.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: { 
                aView.transform = .identity
            }, completion: nil)
        }
    }
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        print("点击了我")
        start = myPin.coordinate
        end = view.annotation.coordinate
        guard let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude)),
        let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude)) else {
            return
        }
        walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
    //渲染线路,否则只有overlay(polyline)但是显示不出来(注意当执行路线计算成功的代理回调时应该把先前的路线都去掉)
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            myPin.isLockedToScreen = false
            //地图应该显示路线图所在的区域
            mapView.visibleMapRect = overlay.boundingMapRect
            let render:MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            render.lineWidth = 5
            render.strokeColor = UIColor.blue
            return render
        }
        return nil
    }
}
//MARK:搜索功能代理
extension ViewController:AMapSearchDelegate{
    func searchBikeNearby(){
        searchCustomLocation(mapView.userLocation.coordinate)
    }
    func searchCustomLocation(_ center:CLLocationCoordinate2D){
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude:CGFloat( center.longitude))
        request.keywords = "餐馆"
        request.radius = 500
        request.requireExtension = true
        search.aMapPOIAroundSearch(request)
    }
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        guard (response?.count) != nil else{
            print("周边没有小黄车")
            return
        }
//        for poi in response.pois {
//            ///dump(poi)获取POI对象的代码结构信息,和poi.的属性信息有区别
//            print(poi.name)
//        }
        
        var annotations = [MAPointAnnotation]()
//        annotations = response.pois.map({ (<#AMapPOI#>) -> T in
//            <#code#>
//        })
        //搜索到的pois和小图标的转换
        annotations = response.pois.map{
            let annotation = MAPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude:CLLocationDegrees( $0.location.latitude), longitude:CLLocationDegrees( $0.location.longitude))
            if $0.distance < 200{
                annotation.title = "红色区域内开锁任意小黄车"
                annotation.subtitle = "骑行10分钟领取现金红包"
            }else{
                annotation.title = "可以正常解锁"
            }
            return annotation
        }
        //将搜索到的(数组转换)小图标显示在地图上
        mapView.addAnnotations(annotations)
        if nearBy {
            //将小图标全部显示在屏幕里(这样黑图标会跟着移动)
            mapView.showAnnotations(annotations, animated: true)
            nearBy = !nearBy
        }
        
    }
}
//MARK:UI布局
extension ViewController{
    
   fileprivate func setupUI(){
        //转换方向
        imageView.image = #imageLiteral(resourceName: "whiteImage").rotate(UIImageOrientation(rawValue: 5)!)
        setupNavi()
        setupRevealVC()
        //搜索功能
        //search = AMapSearchAPI()
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











