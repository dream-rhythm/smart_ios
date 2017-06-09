//
//  LoginVC.swift
//  smart_ios
//
//  Created by WaterMoon on 2017/5/20.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import Foundation

import UIKit


class LoginVC: BaseViewController{
    
    var user:User?
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func login(_ sender: Any) {
        user?.login(userName: userName.text!, userPasseord: password.text!)
    }
    @IBAction func check(_ sender: Any) {
        if(user?.isConnect())!{
            print("Yes")
        }
        else{
            print("No")
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="登入"
        user = User()
        user?.login(userName: "123", userPasseord: "123")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
