//
//  MapVC.swift
//  smart_ios
//
//  Created by 吳懿修 on 2017/2/16.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import UIKit
import CoreLocation

class MapVC: BaseViewController, CLLocationManagerDelegate{
    
    let sails = Sails()
    let sailsMapView = SailsLocationMapView(frame: UIScreen.main.bounds)
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="Maps"
       
        locationManager.delegate = self
        
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways{
                locationManager.requestAlwaysAuthorization()
            }
        }
        //var test = LocationRegion()
        //var test2 = GeoNode(logitude: <#T##Double#>, latitude: <#T##Double#>)
        self.view = sailsMapView
        sails.setSailsLocationMapView(sailsMapView)
        sails.loadCloudBuilding("11368c21cf464c1aa587b7ede79aab8b", buildingID: "5405920d1ff15731210001f3", success: (() -> Void)?{
            self.sails.startLocatingEngine()
            let floorNameList = self.sails.getFloorNameList()
            self.sailsMapView.loadFloorMap(floorNameList?[0] as! String?)
            self.sailsMapView.startAnimation(toZoom: 18)
            self.view.backgroundColor = UIColor.white
        }, failure: {(e:Error?)in })
        
        /*
         NSMutableArray *leftItems = [[NSMutableArray alloc] init];
         mBarButtonFloor = [[UIBarButtonItem alloc] initWithTitle:@"Floor" style:UIBarButtonItemStylePlain target:self action:@selector(onNaviBarButtonFloorClick:)];
        [leftItems addObject:mBarButtonFloor];
        self.navigationItem.leftBarButtonItems = leftItems;*/
        
        /*let rightItems = NSMutableArray()
        let floorButton = UIBarButtonItem(title: "Floor", style: UIBarButtonItemStyle.plain, target: self, action: #selector(openfloorlist))
        /*floorButton.setTitle("Floor", for: .normal)
        floorButton.addTarget(self, action: #selector(openfloorlist), for:.touchUpInside)*/
        rightItems.add(floorButton)
        self.navigationItem.rightBarButtonItem = floorButton*/
        
        let zoomInButton = UIButton(type: .custom)
        zoomInButton.addTarget(self, action: #selector(zoomInButtonClicked), for: .touchUpInside)
        zoomInButton.setImage(UIImage(named:"zoomin"), for: .normal)
        zoomInButton.setImage(UIImage(named:"zoomin_p"), for: .highlighted)
        zoomInButton.frame=CGRect(x: 0, y: 0, width: 45, height: 45)
        zoomInButton.center=CGPoint(x: 360, y: UIScreen.main.bounds.height*20/24)
        self.view.addSubview(zoomInButton)
        
        let zoomOutButton = UIButton(type: .custom)
        zoomOutButton.addTarget(self, action: #selector(zoomOutButtonClicked), for: .touchUpInside)
        zoomOutButton.setImage(UIImage(named:"zoomout"), for: .normal)
        zoomOutButton.setImage(UIImage(named:"zoomout_p"), for: .highlighted)
        zoomOutButton.frame=CGRect(x: 0, y: 0, width: 45, height: 45)
        zoomOutButton.center=CGPoint(x: 360, y: UIScreen.main.bounds.height*20/24+45)
        self.view.addSubview(zoomOutButton)
        
        let LocationButton = UIButton(type: .custom)
        LocationButton.addTarget(self, action: #selector(lockCenterButtonClicked), for: .touchUpInside)
        LocationButton.setImage(UIImage(named:"lockCenter1"), for: .normal)
        LocationButton.frame=CGRect(x: 0, y: 0, width: 45, height: 45)
        LocationButton.center=CGPoint(x: 30, y: UIScreen.main.bounds.height*20/24+45)
        LocationButton.tag=1
        self.view.addSubview(LocationButton)
        
        // Do any additional setup after loading the view.
    }
    func lockCenterButtonClicked(){
        if(sailsMapView.isCenterLock()){
            sailsMapView.setMapControlMode(SailsMapControlMode.FollowPhoneHeagingMode)
        }
        else{
            sailsMapView.setMapControlMode(SailsMapControlMode.GeneralMode)
        }
    }
    func zoomInButtonClicked(){
        sailsMapView.zoomIn()
    }
    func zoomOutButtonClicked(){
        let nowLevel = sailsMapView.getZoomLevel()
        if(nowLevel>=18){
            sailsMapView.zoomOut()
        }
    }
    func openfloorlist(){
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.sails.clear()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
