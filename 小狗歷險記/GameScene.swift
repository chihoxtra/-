//
//  GameScene.swift
//  小狗歷險記
//
//  Created by pun samuel on 2/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import SpriteKit

var astroidArray: [String:UIImage] = [
    "banana" : UIImage(named: "banana")!,
    "poison" : UIImage(named: "poison")!,
    "astroid" : UIImage(named: "astroid")!,
    "lo" : UIImage(named: "lo")!
]


var astroidNameArray:[String] {
    get{
        return Array(astroidArray.keys)
    }
}



var tmp = 0

class GameScene: SKScene {


    func spawnObjects() {

        // randomize which object to appear
        let randomIndex = Int(arc4random_uniform(UInt32(astroidArray.count)))

        let sprite = SKSpriteNode(imageNamed: String(astroidNameArray[randomIndex]))

        // calculate the horizontial position wft screen width and marginal buffer value
        let posX = Int(arc4random_uniform(UInt32(self.frame.size.width-300)))+200
        
        print(Int32(self.frame.size.width))
        
        
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        sprite.position = CGPoint(x: CGFloat(posX), y: ((self.frame.size.height)-150))
        
        //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        let a = SKAction.moveToY(100.00, duration: 2)
        
        self.addChild(sprite)
        
        sprite.runAction(SKAction.repeatActionForever(a))
        
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        /* set timer */
        _ = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"poison")
            
            print(location)
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            let a = SKAction.moveToY(100.00, duration: 3)
            
            self.addChild(sprite)
            
            sprite.runAction(SKAction.repeatActionForever(a))
            
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        

        

    }
}
