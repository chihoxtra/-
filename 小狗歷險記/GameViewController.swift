//
//  GameViewController.swift
//  小狗歷險記
//
//  Created by pun samuel on 2/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var currentGame: GameScene!
    
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelDie: UILabel!
    
    @IBOutlet weak var imageSmallDog: UIImageView!

    @IBOutlet weak var labelScore: UILabel!
    
    func updateScore(s: Int) {
        labelScore.text = "分數: " + String(s)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            /* Game Scene will be run after the presentation */
            
            currentGame = scene
            scene.viewController = self
            
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
