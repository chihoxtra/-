//
//  GameScene.swift
//  小狗歷險記
//
//  Created by pun samuel on 2/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameStatus: Bool = false
    
    var smallDogSprite: SKSpriteNode!
    
//    var objectsArray: [String:UIImage] = [
//        "bananas" : UIImage(named: "bananas")!,
//        "cherry" : UIImage(named: "cherry.png")!,
//        "orange" : UIImage(named: "orange.png")!,
//        "poison" : UIImage(named: "poison")!,
//        "heart" : UIImage(named: "heart.png")!,
//        "astroid" : UIImage(named: "astroid")!,
//        "lo" : UIImage(named: "lo")!
//    ]
    
    var objectsWeightArray: [Int] = [
        10,
        10,
        10,
        2,
        1,
        5,
        1
    ]
    
    var objectsNameArray:[String] = ["bananas", "cherry", "orange", "poison", "heart", "astroid", "lo"]

    var newWeighedObjectsArray: [String] = []
    
    // objects generation Interval
    var generationInterval:NSTimeInterval = NSTimeInterval(1.0)
    
    // small dog movement velocity
    var hVel = 250.0
    
    // g for objects to fall
    var gVel = 250.0
    
    // gtimer
    var spawnMachine : NSTimer = NSTimer()
    var gameTimer : NSTimer = NSTimer()
    
    // game level
    var gGameLevel = 1
    var gLevelRaiseInterval:NSTimeInterval = NSTimeInterval(5.0)
    
    // score
    var score: Int = 0
    var scoreFlag: Bool = false
    var totalHeartNumber = 5
    var heartLeft = 5
    var heartScoreArray = [SKSpriteNode()]
    
    // tmp body node, sorry need this to avoid double counting action
    var tmpBody: SKPhysicsBody! = nil
    var tmpBody1: SKPhysicsBody! = nil
    
    // reference to view controller to access items (like images) there
    weak var viewController: GameViewController!

    
    //init categoryBitMask for colllision:
    let objectsCategory:UInt32 = 0x1 << 1
    let smallDogCategory:UInt32 = 0x1 << 2
    let gameBorderCategory:UInt32 = 0x1 << 3
    
    func addHeart () {
        if heartLeft < totalHeartNumber {
                let heartScoreSprite = SKSpriteNode(imageNamed:"heart")
                heartScoreSprite.size = CGSize(width: 40, height: 40)
                heartScoreSprite.position.x = 420 + CGFloat((heartLeft+1) * 50)  /*   next is 185 */
                heartScoreSprite.position.y = 710
                heartLeft++
                heartScoreSprite.name = "heartScore" + String(heartLeft)
                heartScoreArray.append(heartScoreSprite)
                self.addChild(heartScoreSprite)
                print(heartLeft)

        }
    }
    
    
    // spawning new falling objects
    func spawnObjects() {

        
        // randomize which object to appear
        
        let randomIndex = Int(arc4random_uniform(UInt32(newWeighedObjectsArray.count)))
        

        let sprite = SKSpriteNode(imageNamed: String(newWeighedObjectsArray[randomIndex]))
        
        // assign a name for easier logic handling later
        sprite.name = String(newWeighedObjectsArray[randomIndex])
        
        // for collision
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody?.categoryBitMask = objectsCategory
        sprite.physicsBody?.contactTestBitMask = smallDogCategory
        // sprite.physicsBody?.collisionBitMask = smallDogCategory
        
        // immune from collision actions
        sprite.physicsBody?.dynamic = true

        
        // calculate the horizontial position wft screen width and marginal buffer value
        let posX = Int(arc4random_uniform(UInt32(self.frame.size.width-700)))+300
        
        sprite.xScale = 0.3
        sprite.yScale = 0.3
        sprite.position = CGPoint(x: CGFloat(posX), y: ((self.frame.size.height)-150))
        
        let a = SKAction.moveToY(-100.00, duration: 800/gVel)
        
        
        self.addChild(sprite)
        
        sprite.runAction(SKAction.repeatActionForever(a), withKey: "falling")
        
    }
    
    /* Almost like Init() */
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // start the game
        gameStatus = true
        
        // enable physics
        self.physicsWorld.contactDelegate = self

        /* set timer and objects spawn */
        
        spawnMachine = NSTimer.scheduledTimerWithTimeInterval(generationInterval, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(gLevelRaiseInterval, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        
        /* Preparing weighted Array */

        for j in 0 ... objectsWeightArray.count-1 {
            for _ in 0 ... objectsWeightArray[j]-1 {

                newWeighedObjectsArray.append(String(objectsNameArray[j]))
            }

        }
        
        /* prepare hearts and score */


        for i in 1 ... totalHeartNumber {
            let heartScoreSprite = SKSpriteNode(imageNamed:"heart")
            heartScoreSprite.size = CGSize(width: 40, height: 40)
            heartScoreSprite.position.x = 420 + CGFloat(i * 50)  /*   next is 185 */
            heartScoreSprite.position.y = 710
            heartScoreSprite.name = "heartScore" + String(i)
            heartScoreArray.append(heartScoreSprite)
            self.addChild(heartScoreSprite)
        }
        


        /* add ground with frame */
        let gameBorder = SKNode()
        gameBorder.position = CGPointMake(0, 0)
        gameBorder.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        gameBorder.physicsBody?.dynamic = true //This should be set to true
        gameBorder.physicsBody?.affectedByGravity = false
        gameBorder.physicsBody?.friction = 1
        gameBorder.physicsBody?.categoryBitMask = gameBorderCategory
        gameBorder.physicsBody?.contactTestBitMask = objectsCategory
        
        gameBorder.name = "gameBorder"
        self.addChild(gameBorder)
        
        // set small dog node info
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
        smallDogSprite.physicsBody?.contactTestBitMask = objectsCategory
        
        // immune from collision actions
        smallDogSprite.physicsBody?.dynamic = false

        // smallDogSprite.physicsBody?.collisionBitMask = objectsCategory
        
        self.addChild(smallDogSprite)

    }
    
    /* when a touch was made to the game scene */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        

        for touch in touches {
            let location = touch.locationInNode(self)
            let absNumber = abs(Double(smallDogSprite.position.x - location.x))
            
            if (location.y < 400) && (hVel > 0) && (absNumber > 2){
                let t = NSTimeInterval(absNumber/hVel)
                
                print(t)
                
                let a = SKAction.moveToX(location.x, duration: t)
                smallDogSprite.runAction(SKAction.repeatActionForever(a))
                // smallDogSprite.position.x = location.x
            }
            
        }
    }
    
    func removeSprite (body: SKPhysicsBody) {
        
        var tmpNode = SKNode()
        tmpNode = (body.node)!
        var tmpNodeArray: [SKNode] = []
        tmpNodeArray.append(tmpNode)
        
        self.removeActionForKey("falling")
        self.removeChildrenInArray(tmpNodeArray)
        
    }
    
    /* End of Game */
    func gameEnd() {
        gameStatus = false
        
        spawnMachine.invalidate()
        gameTimer.invalidate()
        
        self.removeAllChildren()
        self.removeAllActions()
        viewController.labelDie.hidden = false
        
    }
    
    /* Collison between objects occur */
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
        
        if (firstBody.isEqual(tmpBody)) {
            // do nothing? cause this one has touched before
            
        } else {

            if secondBody.node?.name == "smallDog" {
                
                /* For heart counting */
                if (firstBody.isEqual(tmpBody1)) {
                    // do nothing? cause this one has touched HEART before
                } else {
                
                    
                    /* Start of switch loop */
                    switch firstBody.node?.name {
                    case "poison"?:
                        if heartLeft > 1 {
                            
                            var tmpNode = SKNode()
                            tmpNode = self.childNodeWithName("heartScore" + String(heartLeft))!
                            var tmpNodeArray: [SKNode] = []
                            tmpNodeArray.append(tmpNode)
                            self.removeChildrenInArray(tmpNodeArray)
                            
                            removeSprite (firstBody)
                            
                            tmpBody1 = firstBody
                            
                            heartLeft--
                        } else {
                            gameEnd()
                        }
                    case "lo"?:
                        tmpBody1 = firstBody
                        gameEnd()
                    case "heart"?:
                        removeSprite (firstBody)
                        
                        addHeart()
                        tmpBody1 = firstBody
                    case "astroid"?:
                        /* Just bounce off */
                        tmpBody1 = firstBody
                    default:
                        tmpBody1 = firstBody
                        removeSprite (firstBody)
                        
                        score++
                        viewController!.updateScore(score)
                    }
                    /* end of switch loop */
                    
                
                }
            } else if secondBody.node?.name == "gameBorder" {
                if (firstBody.node) != nil {
                    removeSprite (firstBody)

            }
            
        }
//       print("小孩數目 ： " + String(self.children.count))
        
        
//        if firstBody.categoryBitMask==0 && secondBody.categoryBitMask==1 {
//
//        }
 
        }
    }
    
    
    /* increase level!!! */
    func levelIncrement(t: NSTimeInterval) {
        
        spawnMachine.invalidate()
        viewController.labelLevel.text = "Level: " + String(gGameLevel)
        
//        UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//            // empty block
//            }, completion: { (value: Bool) in
//        
//                UIView.animateWithDuration(2.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//                    
//                    self.viewController?.labelLevel.center.x = 150
//                
//                    }, completion: nil)
//        
//        
//        })



        spawnMachine = NSTimer.scheduledTimerWithTimeInterval(t, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        
    }
    
    func updateTimer() {
        switch gGameLevel {
        case 1:
            gGameLevel++
            gVel += 50
            levelIncrement(generationInterval)
        case 2:
            gGameLevel++
            gVel += 50
            levelIncrement(generationInterval)
        case 3:
            gGameLevel++
            generationInterval *= 0.5
            levelIncrement(generationInterval)
        case 4:
            gGameLevel++
            generationInterval *= 0.5
            
            levelIncrement(generationInterval)
            
        case 5:
            gGameLevel++
            generationInterval *= 0.5
            gVel -= 100
            levelIncrement(generationInterval)
            
        case 6:
            gGameLevel++
            generationInterval *= 0.2
            gVel -= 150
            levelIncrement(generationInterval)

        default: break
        }
    }
   

}
