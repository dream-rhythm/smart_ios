//
//  User.swift
//  smart_ios
//
//  Created by WaterMoon on 2017/5/20.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import Foundation
import UIKit


class User:NSObject,GCDAsyncSocketDelegate{
    var userName=""
    var socket:GCDAsyncSocket?
    
    override init(){
        super.init()
        socket=GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        do{
            try socket!.connect(toHost: "192.168.0.101", onPort: 7777, withTimeout: TimeInterval(10))
            print("succed")
        }catch _{
            print("failed")
        }
        //self.userName = ""
    }
    func isConnect()->Bool{
        return socket!.isConnected
    }
    func output(outText:String)  {
        if(socket!.isConnected==false){
        }
        else{
            print("out2="+outText)
            socket!.write(outText.data(using: String.Encoding.utf8)! as Data, withTimeout: -1, tag: 1)
            //socket?.disconnect()
            //socket?.writeStream()
            //socket?.readData( withTimeout: 0.1, tag: 1)
            /*let requestData = outText.data(using:String.Encoding.utf8)
            var length = outText.lengthOfBytes(using: String.Encoding.utf8)
            length = length.bigEndian
            let lengthData = NSData(bytes:&length,length:MemoryLayout<Int32>.size)
            let data = NSMutableData(data: lengthData as Data)
            data.append(requestData!)
            
            socket!.write(data as Data, withTimeout: -1, tag: 1)*/
            /*
             NSDictionary *req = @{KEY_REQUEST: request,
             KEY_COMPLETE_HANDLER: completeHandler};
             [_requests addObject:req];
             
             NSData *requestData = request.data;
             int32_t length = [requestData length];
             length = htonl(length);
             NSData *lengthData = [NSData dataWithBytes:&length length:sizeof(int32_t)];
             
             NSMutableData *data = [[NSMutableData alloc] initWithData:lengthData];
             [data appendData:requestData];
             [_socket writeData:data withTimeout:30 tag:REQUEST_TAG];

             */
            
        }
        
    }
    func login(userName:String,userPasseord:String){
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(userName, forKey: "userName")
        jsonObject.setValue(userPasseord, forKey: "userPasswd")
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            self.output(outText: jsonString)
            //print("json string = \(jsonString)")
            
        } catch _ {
            print ("JSON Failure")
        }
    }
    
    func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        print("Connected to server.")
    }
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:Int32) {
        print("send?")
    }
    func socket(_ didReadsock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msg = String(data: data as Data, encoding: String.Encoding.utf8)
        //addText(msg!)
        print("server="+msg!)
        socket?.readData(withTimeout: -1, tag: 1)
    }
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        socket!.readData( withTimeout: -1, tag: 1)
        print("send succed")
    }
    
}
