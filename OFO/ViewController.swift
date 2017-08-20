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
    var mypinView : MAAnnotationView!
    var pinView : MAAnnotationView!
    var nearBy :Bool! = true
    var start,end :CLLocationCoordinate2D!
    var polyLine:MAPolyline!
    var naviWalkView : AMapNaviWalkView!
    
    lazy var mapView = MAMapView(frame: UIScreen.main.bounds)
    /// '?' must be followed by a call, member lookup, or subscript
    lazy var search :AMapSearchAPI = AMapSearchAPI()
    
    lazy var centerPin : MyPinAnnotation = MyPinAnnotation()
    
    lazy var walkManager:AMapNaviWalkManager = AMapNaviWalkManager()
   
    lazy var shapelayer:CAShapeLayer = CAShapeLayer()
    
    deinit {
        walkManager.stopNavi()
        walkManager.delegate = nil
        
    }
    
    @IBAction func LocationBtnTap(_ sender: UIButton) {
        nearBy = true
        searchBikeNearby()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMapSystem()
        
    }

}

//MARK:动画代理
extension ViewController:CAAnimationDelegate{

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.mapView.add(self.polyLine)
        shapelayer.removeFromSuperlayer()
    }
}

//MARK:导航图像代理
extension ViewController:AMapNaviWalkViewDelegate{
    
}
//MARK:导航步行路线规划
extension ViewController:AMapNaviWalkManagerDelegate{
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        print("规划成功")
        // mapView.add(polyLine)添加的overlay都在这里销毁了否则地图都是线
        mapView.removeOverlays(mapView.overlays)
        var coordinates = walkManager.naviRoute!.routeCoordinates.map{
            return CLLocationCoordinate2D(latitude:CLLocationDegrees( $0.latitude), longitude:CLLocationDegrees($0.longitude))
        }
        //这里的这线图就是render的overlay
//        guard let polyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count)) else {
//            return
//        }
        guard let polyline = MAPolyline.init(coordinates: &coordinates, count: UInt(coordinates.count)) else {
            return
        }
        polyLine = polyline
        let path = UIBezierPath()
        for i in 0..<Int( polyline.pointCount){
            let mp = polyline.points[i] as MAMapPoint
            if i==0 {
            path.move(to: pointForMapPoint(mapPoint: mp))
            }else{
                path.addLine(to: pointForMapPoint(mapPoint: mp))
            }
        }
        //创建shapeLayer
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.blue.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4
        mapView.layer.addSublayer(layer)
        //创建动画
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = true
        animation.delegate = self as CAAnimationDelegate
        
        layer.add(animation, forKey: nil)
        shapelayer = layer
        //mapView.add(polyline)
        alertAction(routeTime: walkManager.naviRoute!.routeTime, routeLength:walkManager.naviRoute!.routeLength)
    }
    func pointForMapPoint(mapPoint:MAMapPoint)->CGPoint{
        var point = CGPoint()
        let viewWidth = Double(mapView.bounds.width)
        let viewHeight = Double(mapView.bounds.height)
        let rect = mapView.visibleMapRect;
        let scaleW = rect.size.width/viewWidth
        let scaleH = rect.size.height/viewHeight
        point.x = CGFloat((mapPoint.x - rect.origin.x) / scaleW);
        point.y = CGFloat((mapPoint.y - rect.origin.y) / scaleH);
        return point
        
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

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        //如果是用户图标不自定义,返回就行了
        if annotation is MAUserLocation{
            let reuseId = "myId"
            var myPinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MAPinAnnotationView
            if myPinView == nil {
                myPinView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            myPinView?.canShowCallout = false
            
            mypinView = myPinView
            return myPinView
        }
        if annotation is MyPinAnnotation {
            let reuseId = "centerId"
            var centerPinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MAPinAnnotationView
            if centerPinView == nil {
                centerPinView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            centerPinView?.canShowCallout = false
            centerPinView?.image = #imageLiteral(resourceName: "homePage_wholeAnchor")
            pinView = centerPinView
            return centerPinView
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
    
        centerPin.coordinate = mapView.centerCoordinate
        centerPin.lockedScreenPoint = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        centerPin.isLockedToScreen = true
        //小黄车和大头钉一块儿显示
        mapView.addAnnotation(centerPin)
        mapView.showAnnotations([centerPin], animated: true)
        searchBikeNearby()
    }
    //移动地图的交互
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            
            //中心图标不能更改,否则定位范围不会改变
            centerPin.isLockedToScreen = true
            
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
        start = mypinView.annotation.coordinate
        //start = myPin.coordinate
        end = view.annotation.coordinate
        guard let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude)),
        let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude)) else {
            return
        }
        walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
    //点击任意点
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        
    }
    //渲染线路,否则只有overlay(polyline)但是显示不出来(注意当执行路线计算成功的代理回调时应该把先前的路线都去掉)
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            centerPin.isLockedToScreen = false
            //地图应该显示路线图所在的区域
            mapView.visibleMapRect = overlay.boundingMapRect
            let render:MAPolylineRenderer = MAPolylineRenderer(polyline: polyLine)
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
    
    fileprivate func setupMapSystem(){
        mapView.delegate = self as MAMapViewDelegate
        search.delegate = self as AMapSearchDelegate
//        initWalkView()
        walkManager.delegate = self as AMapNaviWalkManagerDelegate
        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
//        walkManager.addDataRepresentative(naviWalkView)
        //地图一打开的精度越大越精准
        mapView.zoomLevel = 15
        //一直追踪定位,可将定位放在地图中间并自动放大区域
        mapView.userTrackingMode = .follow
        //先定位在追踪,否则不显示蓝点.(注意顺序)
        mapView.showsUserLocation = true
        //关闭相机旋转,降低能耗
        mapView.isRotateCameraEnabled = false
        
        
    }
    func initWalkView(){
        naviWalkView = AMapNaviWalkView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        naviWalkView.delegate = self
        naviWalkView.normalTexture = #imageLiteral(resourceName: "HomePage_path")
        view.addSubview(naviWalkView)
    }
    
   fileprivate func setupUI(){
        view.insertSubview(mapView, belowSubview: toolbarView)
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











