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

class StreamVC: BaseViewController {
    //let videoURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    //let videoURL = NSURL(string: "http:192.168.0.106:8080")
    let player = AVPlayer(url: NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")! as URL)

    
    @IBAction func map(_ sender: Any) {
        self.openViewControllerBasedOnIdentifier("MapVC")
        player.pause();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        player.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        self.title="即時畫面"
        let screenSize: CGRect = UIScreen.main.bounds
        
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 57, width: screenSize.width, height: screenSize.height/3)
        self.view.layer.addSublayer(playerLayer)
        player.play()
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
