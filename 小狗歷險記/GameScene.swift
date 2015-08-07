//
//  GameScene.swift
//  小狗歷險記
//
//  Created by pun samuel on 2/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import SpriteKit





var smallDogSprite: SKSpriteNode!

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var astroidArray: [String:UIImage] = [
        "bananas" : UIImage(named: "bananas")!,
        "poison" : UIImage(named: "poison")!,
        "astroid" : UIImage(named: "astroid")!,
        "lo" : UIImage(named: "lo")!
    ]
    
    
    var astroidNameArray:[String] {
        get{
            return Array(astroidArray.keys)
        }
    }
    
    // objects generation speed
    var fallTempo = 1.0
    
    // score
    var score: Int = 0
    var scoreFlag: Bool = false
    
    // tmp body node
    var tmpBody: SKPhysicsBody! = nil
    
    // reference to view controller to access items (like images) there
    weak var viewController: GameViewController!

    
    //init categoryBitMask for colllision:
    let astroidsCategory:UInt32 = 0x1 << 1
    let smallDogCategory:UInt32 = 0x1 << 2
    
    func spawnObjects() {

        // randomize which object to appear
        let randomIndex = Int(arc4random_uniform(UInt32(astroidArray.count)))

        let sprite = SKSpriteNode(imageNamed: String(astroidNameArray[randomIndex]))
        
        // assign a name for easier logic handling later
        sprite.name = String(astroidNameArray[randomIndex])
        
        // for collision
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody?.categoryBitMask = astroidsCategory
        sprite.physicsBody?.contactTestBitMask = smallDogCategory
        // sprite.physicsBody?.collisionBitMask = smallDogCategory
        
        // immune from collision actions
        sprite.physicsBody?.dynamic = true

        
        // calculate the horizontial position wft screen width and marginal buffer value
        let posX = Int(arc4random_uniform(UInt32(self.frame.size.width-300)))+200
        
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        sprite.position = CGPoint(x: CGFloat(posX), y: ((self.frame.size.height)-150))
        
        //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        let a = SKAction.moveToY(-100.00, duration: 2)
        
        
        self.addChild(sprite)
        
        sprite.runAction(SKAction.repeatActionForever(a))
        
    }
    
    /* Almost like Init() */
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self

        /* set timer */
        _ = NSTimer.scheduledTimerWithTimeInterval(fallTempo, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        
        smallDogSprite = SKSpriteNode(imageNamed:"smallDog")
        
        // assign a name for easier logic handling later
        smallDogSprite.name = String("smallDog")
        
        smallDogSprite.xScale = 0.8
        smallDogSprite.yScale = 0.8
        smallDogSprite.position.x = 510.0
        smallDogSprite.position.y = 120.0
        
        //init smallDog
        smallDogSprite.physicsBody = SKPhysicsBody(rectangleOfSize: smallDogSprite.size)
        smallDogSprite.physicsBody?.categoryBitMask = smallDogCategory
        smallDogSprite.physicsBody?.contactTestBitMask = astroidsCategory
        
        // immune from collision actions
        smallDogSprite.physicsBody?.dynamic = false

        // smallDogSprite.physicsBody?.collisionBitMask = astroidsCategory
        
        self.addChild(smallDogSprite)

    }
    
    /* when a touch was made to the game scene */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)

            if location.y < 200 {
                let a = SKAction.moveToX(location.x, duration: 0.5)
                smallDogSprite.runAction(SKAction.repeatActionForever(a))
                // smallDogSprite.position.x = location.x
            }
            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
            
            
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.isEqual(tmpBody) {
            // do nothing?
            print((firstBody.node?.name)! + " touched again!")
        } else {
            tmpBody = firstBody
            print("new object: " + (firstBody.node?.name)! + " touched! ")
            print(score++)
            
        }
    
        
        
        if firstBody.categoryBitMask==0 && secondBody.categoryBitMask==1 {
//
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

    }
}
