//
//  ViewController.swift
//  smart_ios
//
//  Created by WaterMoon on 2017/2/15.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//

import UIKit
extension NSData{
    func getByteArray()->[UInt8]?{
        var ByteArray:[UInt8]=[UInt8]()
        for i in 0..<self.length{
            var temp:UInt8 = 0
            self.getBytes(&temp, range: NSRange(location: i,length: 1))
            ByteArray.append(temp)
        }
        return ByteArray
    }
}

class ViewController: BaseViewController ,GCDAsyncSocketDelegate{
    
    @IBOutlet weak var TextBox: UITextField!
    
    var socket:GCDAsyncSocket!

    
    @IBAction func ButtonClick(_ sender: Any) {
        let Textdata = (TextBox.text?.data(using: String.Encoding.utf8))!
       // nc -lk 8000 可觀察socket情形
        socket!.write(Textdata, withTimeout: 10, tag: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.addSlideMenuButton()
        socket=GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        do{
            try socket.connect(toHost: "localhost", onPort: 8000)
            print("success")
        }catch _{
            print("error")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

