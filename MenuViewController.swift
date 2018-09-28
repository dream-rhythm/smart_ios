//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
    *  Array to display menu options
    */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
    *  Array containing menu options
    */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    var loginName = ""
    public func setLoginName(name:String){
        loginName = name
    }
    
    /**
    *  Delegate of the MenuVC
    */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        
        arrayMenuOptions.append(["title":"Home", "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":"Login","icon":"LoginIcon"])
        arrayMenuOptions.append(["title":"查看地圖", "icon":"MapIcon"])
        //arrayMenuOptions.append(["title":"Campus Guide","icon":"NagivationIcon"])
        //arrayMenuOptions.append(["title":"Find Friend","icon":"FindFriendIcon"])
        arrayMenuOptions.append(["title":"My Video","icon":"StudentIcon"])
        arrayMenuOptions.append(["title":"Live Sense","icon":"StreamIcon"])
        //arrayMenuOptions.append(["title":"SOS","icon":"EmergencyIcon"])
        arrayMenuOptions.append(["title":"我的寶貝","icon":"BabyIcon"])
        //arrayMenuOptions.append(["title":"系統設定","icon":"SettingIcon"])
        
        tblMenuOptions.reloadData()
    }
    func updateArrayMenuOptions(userName:String){
        
        arrayMenuOptions.append(["title":"首頁", "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":userName,"icon":"LoginIcon"])
        arrayMenuOptions.append(["title":"校園地圖", "icon":"MapIcon"])
        arrayMenuOptions.append(["title":"定位導引","icon":"NagivationIcon"])
        arrayMenuOptions.append(["title":"尋找夥伴","icon":"FindFriendIcon"])
        arrayMenuOptions.append(["title":"學生關懷","icon":"StudentIcon"])
        arrayMenuOptions.append(["title":"即時畫面","icon":"StreamIcon"])
        arrayMenuOptions.append(["title":"緊急通報","icon":"EmergencyIcon"])
        arrayMenuOptions.append(["title":"我的寶貝","icon":"BabyIcon"])
        
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}
