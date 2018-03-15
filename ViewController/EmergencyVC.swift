//
//  EmergencyVC.swift
//  smart_ios
//
//  Created by 吳懿修 on 2017/2/16.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import UIKit

class EmergencyVC: BaseViewController {

    @IBAction func CallTeacher(_ sender: Any) {
        let phoneNumber = URL(string:"tel://002886424515502")!
        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func CallPolice(_ sender: Any) {
        let phoneNumber = URL(string:"tel://100")!
        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="SOS"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
