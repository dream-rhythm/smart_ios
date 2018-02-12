//
//  FindFriendVC.swift
//  smart_ios
//
//  Created by 吳懿修 on 2017/2/16.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import UIKit

class FindFriendVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    var user:User?
    var str = ""
    var tableView = UITableView()
    var dataArr = NSMutableArray()
    
    
    
    @IBAction func refresh(_ sender: Any) {
        
        str = (user?.getData())!
        print(str)
        dataArr=self.getUser(msg: str)
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="夥伴列表"
        user = User()
        user?.autoLogin()
        user?.setStatus(Status: 2)
        dataArr=[]
        tableView = UITableView(frame: CGRect(x:0, y:130, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height), style: UITableViewStyle.plain)
        tableView.dataSource = self as UITableViewDataSource
        tableView.delegate = self as UITableViewDelegate
        self.view.addSubview(tableView)
        
        
        
    }
    func getUser(msg:String)->NSMutableArray{
        let datas = NSMutableArray()
        var msg2=msg
        /*
         if let idx = string.characters.index(of: needle) {
         let pos = string.characters.distance(from: string.startIndex, to: idx)
         print("Found \(needle) at position \(pos)")
         }
         */
        while(msg2.contains("userName") ){
            //let idx=(msg2.range(of: "userName:\"")?.upperBound)!
            var range = msg2.range(of: "userName\":\"")
            //var startPos = msg2.characters.distance(from: msg2.characters.startIndex, to: (range?.lowerBound)!)
            let endPos = msg2.characters.distance(from: msg2.characters.startIndex, to: (range?.upperBound)!)
            var index = msg2.index(msg2.startIndex, offsetBy: endPos)
            var tmp = msg2.substring(from: index)//切出userName後面的東西
            
            range = tmp.range(of: "\"}")
            var startPos = tmp.characters.distance(from: tmp.characters.startIndex, to: (range?.lowerBound)!)
            //endPos = tmp.characters.distance(from: tmp.characters.startIndex, to: (range?.upperBound)!)
            index = tmp.index(tmp.startIndex, offsetBy: startPos)
            
            let tmp2 = tmp.substring(to: index)
            msg2 = tmp.substring(from: index)
            datas.add(tmp2)
        }
        return datas
    }
    
    
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
        
        
        let alertController = UIAlertController(title: "提示", message: "这是第\(indexPath.row)个cell", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        //self.present(alertController, animated: true, completion: nil)
        
        openViewControllerBasedOnIdentifier("Friend2")
        //self.dismiss(animated: true, completion: nil)
        //self.present(Friend2(), animated: true, completion: nil)
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        user?.socket?.disconnect()
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
