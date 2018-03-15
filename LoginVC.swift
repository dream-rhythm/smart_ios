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
        if (user?.isConnect())!{
            let alertController = UIAlertController(
                title: "Message",
                message: "Login Success",
                preferredStyle: .alert)
            
            // 建立[確認]按鈕
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: {
                    (action: UIAlertAction!) -> Void in
                    print("登入成功")
                    
            })
            alertController.addAction(okAction)
            
            // 顯示提示框
            self.present(
                alertController,
                animated: true,
                completion: nil)

        }
        else{
            let alertController = UIAlertController(
                title: "Message",
                message: "Login Failed",
                preferredStyle: .alert)
            
            // 建立[確認]按鈕
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: {
                    (action: UIAlertAction!) -> Void in
                    print("登入失敗")
            })
            alertController.addAction(okAction)
            
            // 顯示提示框
            self.present(
                alertController,
                animated: true,
                completion: nil)
        
        }
    }
    @IBAction func check(_ sender: Any) {
        if(user?.isConnect())!{
            user?.logout()
        }
        else{
            print("No")
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="登入"
        if user == nil {
            user = User()
            /*if(user?.isConnect()==false){
                let alertController = UIAlertController(
                    title: "錯誤",
                    message: "無法連接至伺服器",
                    preferredStyle: .alert)
                
                // 建立[確認]按鈕
                let okAction = UIAlertAction(
                    title: "確認",
                    style: .default,
                    handler: {
                        (action: UIAlertAction!) -> Void in
                        print("登入失敗")
                })
                alertController.addAction(okAction)
                
                // 顯示提示框
                self.present(
                    alertController,
                    animated: true,
                    completion: nil)
            }*/
        }
        //user?.login(userName: "123", userPasseord: "123")
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        user?.logout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
