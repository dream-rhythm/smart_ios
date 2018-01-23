//
//  User.swift
//  smart_ios
//
//  Created by WaterMoon on 2017/5/20.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import CoreData

class User:NSObject,GCDAsyncSocketDelegate{
    var userName=""
    var pass=""
    var name=""
    var socket:GCDAsyncSocket?
    var isLogin=false
    var isAutoLogin = false
    var status = 0;
    var DATA = ""
    
    override init(){
        super.init()
        socket=GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        do{
            try socket!.connect(toHost: self.getIPaddress(), onPort: 7777, withTimeout: TimeInterval(10))
            print("succed")
        }catch _{
            
            print("failed")
        }
        //self.userName = ""
    }
    func isConnect()->Bool{
        return socket!.isConnected
    }
    func logout(){
        socket?.disconnect()
    }
    func output(outText:String)  {
        if(socket!.isConnected==false){
        }
        else{
            print("out2="+outText)
            socket!.write(outText.data(using: String.Encoding.utf8)! as Data, withTimeout: -1, tag: 0)
            socket?.readData(withTimeout:-1 ,tag:1)
                    
        }
        
    }
    func login(userName:String,userPasseord:String){
        do{
            try socket!.connect(toHost: self.getIPaddress(), onPort: 7777, withTimeout: TimeInterval(10))
            print("succed")
        }catch _{
            
            print("failed")
        }
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(userName, forKey: "userName")
        jsonObject.setValue(userPasseord, forKey: "userPasswd")
        
        name = userName
        pass = userPasseord
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            let msg = jsonString.appending("\r\n")
            self.output(outText: msg)
            //print("json string = \(jsonString)")
            
        } catch _ {
            print ("JSON Failure")
        }
    }
    
    func sendStatus(statusNumber:Int32){
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(statusNumber, forKey: "status")
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            let msg = jsonString.appending("\r\n")
            self.output(outText: msg)
            //print("json string = \(jsonString)")
            
        } catch _ {
            print ("JSON Failure")
        }
    }
    
    func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        print("Connected to server.")
        if isAutoLogin{
            let lastName = self.getUserName()
            let lastPass = self.getUserPassword()
            self.login(userName: lastName, userPasseord: lastPass)
        }
    }
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:Int32) {
        print("send?")
    }
    func socket(_ didReadsock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msg = String(data: data as Data, encoding: String.Encoding.utf8)
        //addText(msg!)
        print("server="+msg!)
        /*
        var data2 = msg?.data(using: .utf8,allowLossyConversion: false)!
        let json = try? JSON(data:data2)
        if(json[]=="登入成功"){
            
        }*/
        if(msg?.contains("登入成功"))!{
            print("Login success\n")
            setUserInfo(userName: name, userPasseord: pass)
            self.isLogin=true
            if(status==2){
                sendStatus(statusNumber: 2)
            }
        }
        else{
            DATA = msg!
        }
        socket?.readData(withTimeout: -1, tag: 1)
    }
    func isLoginSuccess()->Bool{
        return self.isLogin
    }
    func autoLogin(){
        isAutoLogin = true
    }
    func setStatus(Status:Int){
        status = Status
    }
    func getData()->String{
        return DATA
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
                ipAddress="49.213.156.148"
            }
            
        }catch{
            ipAddress="49.213.156.148"
            print("err\n")
        }
        return ipAddress
    }
    func getUserName()->String{
        var number=0
        let dataRequest : NSFetchRequest<UserInfo>  =  UserInfo.fetchRequest()
        var ans = ""
        do{
            let result = try UseCoreData.getContext().fetch(dataRequest)
            number = result.count
            if(number != 0){
                ans = result[0].username!
            }
            else{
                ans=""
            }
            
        }catch{
            ans=""
            print("err\n")
        }
        print("name="+ans+"\n")
        return ans
    }
    func getUserPassword()->String{
        var number=0
        let dataRequest : NSFetchRequest<UserInfo>  =  UserInfo.fetchRequest()
        var ans = ""
        do{
            let result = try UseCoreData.getContext().fetch(dataRequest)
            number = result.count
            if(number != 0){
                ans = result[0].password!
            }
            else{
                ans=""
            }
            
        }catch{
            ans=""
            print("err\n")
        }
        print("pass="+ans+"\n")
        return ans
    }
    
    
    func setUserInfo(userName:String,userPasseord:String){
        var number = 0
        let dataRequest : NSFetchRequest<UserInfo>  =  UserInfo.fetchRequest()
        
        do{
            let result = try UseCoreData.getContext().fetch(dataRequest)
            number = result.count
            
            if(number != 0){
                result[0].password = userPasseord
                result[0].username = userName
            }
            else{
                let data = UserInfo(context:UseCoreData.persistentContainer.viewContext)
                data.password = userPasseord
                data.username = userName
            }
            UseCoreData.saveContext()
            
            
            
        }catch{
            print("err\n")
            let data = UserInfo(context:UseCoreData.persistentContainer.viewContext)
            data.password = userPasseord
            data.username = userName
            UseCoreData.saveContext()
            
        }
    }
}
