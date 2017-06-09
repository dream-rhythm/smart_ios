//
//  StreamVC.swift
//  smart_ios
//
//  Created by 吳懿修 on 2017/2/16.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData

class StreamVC: BaseViewController {
    //let videoURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    //let videoURL = URL(string: "http:192.168.0.106:8080")!
    //let player = AVPlayer(url: URL(string: "http:192.168.0.101:8080")!)
    let screenSize: CGRect = UIScreen.main.bounds
    let myWebView = UIWebView()
    
    
    @IBAction func map(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("MapVC")
        //player.pause();
    }
    @IBAction func map_txt(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("MapVC")
    }
    @IBAction func SOS(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("EmergencyVC")
    }
    @IBAction func SOStxt(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("EmergencyVC")
    }
    @IBAction func back(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("Home")
    }
    @IBAction func back_txt(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("Home")
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //player.pause()
        myWebView.stopLoading()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="即時畫面"
        myWebView.frame=CGRect(x: 0, y: 57, width: screenSize.width, height: screenSize.height/3)
        //myWebView.delegate = self
        self.view.addSubview(myWebView)
        //let url = NSURL(string:"http:192.168.0.101:8080"!)
        var url = self.getIPaddress()
        url = "http://"+url + ":8080"
        print(url)
        let urlRequest = NSURLRequest(url: URL(string: url)!)
        myWebView.loadRequest(urlRequest as URLRequest)
        myWebView.scalesPageToFit = true
        myWebView.scrollView.isScrollEnabled=false
        
        //let playerLayer = AVPlayerLayer(player: player)
        //playerLayer.frame = CGRect(x: 0, y: 57, width: screenSize.width, height: screenSize.height/3)
        //self.view.layer.addSublayer(playerLayer)
        //player.play()
        // Do any additional setup after loading the view.
    }
    
    func getIPaddress()->String{
        var number=0
        let dataRequest : NSFetchRequest<Settings>  =  Settings.fetchRequest()
        var ipAddress = ""
        do{
            let result = try UseCoreData.getContext().fetch(dataRequest)
            number = result.count
            if(number != 0){
                ipAddress = result[0].serverIP!
            }
            else{
                ipAddress="192.168.0.1"
            }
            
        }catch{
            ipAddress="192.168.0.1"
            print("err\n")
        }
        return ipAddress
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
