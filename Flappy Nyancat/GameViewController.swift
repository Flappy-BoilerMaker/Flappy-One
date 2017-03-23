//
//  GameViewController.swift
//  Flappy Nyancat
//
//  Created by Frank Hu on 2017/2/21.
//  Copyright © 2017年 Weichu Hu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Thread.sleep(forTimeInterval: 1.5)
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            scene.size = self.view.bounds.size
            
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false  //disable totation
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait   //disable totation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
