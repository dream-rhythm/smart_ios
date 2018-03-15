//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import CoreData

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    var nowVCname=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nowVCname="首頁"
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        //let topViewController : UIViewController = self.navigationController!.topViewController!
        //print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("Home\n", terminator: "")
            nowVCname="首頁"
            self.openViewControllerBasedOnIdentifier("Home")
            
        case 9999:
            print("MapVC\n", terminator: "")
            nowVCname="室內地圖"
            self.openViewControllerBasedOnIdentifier("MapVC")
            
        case 2:
            print("NagivationVC\n", terminator: "")
            nowVCname="定位導引"
            self.openViewControllerBasedOnIdentifier("NagivationVC")
            
        case 3:
            print("FindFriendVC\n",terminator:"")
            nowVCname="尋找夥伴"
            self.openViewControllerBasedOnIdentifier("FindFriendVC")
            
        case 4:
            print("StudentVC\n", terminator: "")
            nowVCname="學生關懷"
            self.openViewControllerBasedOnIdentifier("StudentVC")
            
        case 5:
            print("StreamVC\n",terminator: "")
            nowVCname="即時畫面"
            self.openViewControllerBasedOnIdentifier("StreamVC")
            
        case 6:
            print("EmergencyVC\n",terminator: "")
            nowVCname="緊急通報"
            self.openViewControllerBasedOnIdentifier("EmergencyVC")
        case 1:
            print("LoginVC\n",terminator: "")
            nowVCname="登入頁面"
            self.openViewControllerBasedOnIdentifier("LoginVC")
        case 8:
            print("Mybaby")
            nowVCname="我的寶貝"
            self.openViewControllerBasedOnIdentifier("Mybaby")
        default:
            self.title=nowVCname
            print("default\n", terminator: "")
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            self.title=nowVCname
            print("Same VC")
        } else {
            
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
        
        
        let btnShowSetting = UIButton(type:UIButtonType.system)
        btnShowSetting.setImage(self.defaultSettingImage(), for: UIControlState())
        btnShowSetting.frame=CGRect(x:0,y:0,width:5,height:30)
        btnShowSetting.addTarget(self, action: #selector(BaseViewController.setIPConfigPress(_:)), for: UIControlEvents.touchUpInside)
        let customSettingItem = UIBarButtonItem(customView: btnShowSetting)
        self.navigationItem.rightBarButtonItem = customSettingItem;
    }
    
    func setIPConfigPress(_ sender : UIButton){
        var number = 0
        let dataRequest : NSFetchRequest<Settings>  =  Settings.fetchRequest()
        var ipAddress = ""
        do{
            let result = try UseCoreData.getContext().fetch(dataRequest)
            number = result.count
            if(number != 0){
                ipAddress = result[0].serverIP!
            }
        
            let SettingBox :UIAlertController = UIAlertController(title: "IP Setting", message: "Please input server IP", preferredStyle: .alert)
        
            SettingBox.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "192.168.0.1"
                textField.text = ipAddress
            }
        
            SettingBox.addAction(UIAlertAction(title: "Cancel",style: .cancel,handler: nil))
        
            let okAction = UIAlertAction(title:"OK",style: UIAlertActionStyle.default){
                (action: UIAlertAction!) -> Void in
                let IPAddress = (SettingBox.textFields?.first)! as UITextField
                if(number != 0){
                    result[0].serverIP = IPAddress.text
                }
                else{
                    let data = Settings(context:UseCoreData.persistentContainer.viewContext)
                    data.serverIP = IPAddress.text
                }
                UseCoreData.saveContext()
            }
            
            SettingBox.addAction(okAction)
        
            self.present(SettingBox,animated:true,completion:nil)
            
        }catch{
            print("err\n")
            
            
            let SettingBox2 :UIAlertController = UIAlertController(title: "網路IP設定", message: "請輸入伺服器IP", preferredStyle: .alert)
            
            SettingBox2.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "192.168.0.1"
                textField.text = ipAddress
            }
            
            SettingBox2.addAction(UIAlertAction(title: "取消",style: .cancel,handler: nil))
            
            let okAction = UIAlertAction(title:"確定",style: UIAlertActionStyle.default){
                (action: UIAlertAction!) -> Void in
                let IPAddress = (SettingBox2.textFields?.first)! as UITextField
                let data = Settings(context:UseCoreData.persistentContainer.viewContext)
                data.serverIP = IPAddress.text
                UseCoreData.saveContext()
            }
            
            SettingBox2.addAction(okAction)
            
            self.present(SettingBox2,animated:true,completion:nil)

        }
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
       
        return defaultMenuImage;
    }
    func defaultSettingImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 4, height: 4)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 4, height: 4)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 4, height: 4)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 4, height: 4)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 4, height: 4)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 4, height: 4)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }
    
    func onSlideMenuButtonPressed(_ sender : UIButton){
        //nowVCname=self.title! as String
        self.title="iGuiding"
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
}
