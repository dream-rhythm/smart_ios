//
//  VideoVC.swift
//  smart_ios
//
//  Created by 吳懿修 on 2017/2/16.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData

class StudentVC: BaseViewController,UITableViewDelegate,UITableViewDataSource{
    var user:User?
    let screenSize: CGRect = UIScreen.main.bounds
    let myWebView = UIWebView()
    var video = "Lin0.mp4"
    //@IBOutlet weak var TableView: UITableView!
    var tableView = UITableView()
    var dataArr=NSMutableArray()
    
    let ScreenSize: CGRect = UIScreen.main.bounds
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    //Section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    //行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    
    //cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40;
    }
    
    //cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cell";
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellID)
        
        cell.textLabel?.text = String(dataArr[indexPath.row] as! String)
        //cell.detailTextLabel?.text = "test\(dataArr[indexPath.row])"
        
        
        
        return cell
    }
    
    
    //cell点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row<dataArr.count){
            self.setVideoByName(VideoName: dataArr[indexPath.row] as! String)
        }
        //self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    //@IBOutlet weak var Time2: UILabel!
    override func viewDidDisappear(_ animated: Bool) {
        //player.pause()
        myWebView.loadRequest(NSURLRequest(url: URL(string: "about:blank")!) as URLRequest)
    }
    
    @IBAction func GoToSOS(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("EmergencyVC")
    }
    func reloadTable(){
        user?.sendStatus(statusNumber: 15)
        let msg = user?.getData()
        print(msg ?? "(nil)")
        if(msg==""){
            
        }
        else{
            let videoNames = msg?.components(separatedBy: ",")
            //videoNames = videoNames?.removeLast()
            dataArr = NSMutableArray()
            for element in videoNames! {
                if(element=="\r\n"){
                    
                }
                else{
                    dataArr.add(element)
                }
            }
            //dataArr = videoNames as! NSMutableArray
            if(dataArr.count>1){
                print(dataArr.count)
            }
        }
        
    }
    @IBAction func GoToUpdate(_ sender: Any) {
        //let alertController = UIAlertController(title: "載入中...",message: nil, preferredStyle: .alert)
        //显示提示框
        //self.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        //Thread.sleep(forTimeInterval: 2)
        /*DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }*/
        
        if(self.getIPaddress()=="192.168.43.105"){
            reloadTable()
            Timer.scheduledTimer(timeInterval: 1, target : self, selector : #selector(StudentVC.loadData), userInfo : nil, repeats : false)
            //Thread.sleep(forTimeInterval: 1.5)
            
        }
        else{
            Thread.sleep(forTimeInterval: 2)
            let alertController2 = UIAlertController(title: "Error",
                                                     message: "Can not connect to server...", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController2.addAction(okAction)
            self.present(alertController2, animated: true, completion: nil)
        }
    }
    func loadData(){
        reloadTable()
        let alertController2 = UIAlertController(title: "Message",
                                                 message: "Load Succes", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.reloadTable()
            self.tableView.reloadData()
        })
        alertController2.addAction(okAction)
        self.present(alertController2, animated: true, completion: nil)
        tableView.reloadData()
    }
    @IBAction func GoToGuiding(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("MapVC")
    }
    @IBAction func GoToStream(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("StreamVC")
        myWebView.loadRequest(NSURLRequest(url: URL(string: "about:blank")!) as URLRequest)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        user = User()
        user?.autoLogin()
        //Time2.lineBreakMode =  .byWordWrapping
        self.title="My Video"
        myWebView.frame=CGRect(x: 0, y: 60, width: screenSize.width, height: screenSize.height/3-9)
        //myWebView.delegate = self
        video = "Lin0.mp4"
        self.loadVideo()
        tableView = UITableView(frame: CGRect(x:0, y:379, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height), style: UITableViewStyle.plain)
        tableView.dataSource = self as UITableViewDataSource
        tableView.delegate = self as UITableViewDelegate
        self.view.addSubview(tableView)
        Button1.frame=CGRect(x:ScreenSize.width/2-190, y:290, width:85, height:85)
        Button2.frame=CGRect(x:ScreenSize.width/2-85, y:295, width:85, height:75)
        Button3.frame=CGRect(x:ScreenSize.width/2+5, y:290, width:85, height:85)
        Button4.frame=CGRect(x:ScreenSize.width/2+95, y:290, width:85, height:85)
    }
    func loadVideo(){
        self.view.addSubview(myWebView)
        //let url = NSURL(string:"http:192.168.0.101:8080"!)
        
        self.setVideoByName(VideoName: "pleaseChoose.html")
    }
    func setVideoByName(VideoName:String){
        var url = self.getIPaddress()
        url = "http://"+url + "/iGuiding/"+VideoName
        print(url)
        let urlRequest = NSURLRequest(url: URL(string: url)!)
        myWebView.loadRequest(urlRequest as URLRequest)
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
                ipAddress="192.168.109.2"
            }
            
        }catch{
            ipAddress="192.168.109.2"
            print("err\n")
        }
        return ipAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
