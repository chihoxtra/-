//
//  GameScene.swift
//  小狗歷險記
//
//  Created by pun samuel on 2/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var smallDogSprite: SKSpriteNode!
    
    var astroidArray: [String:UIImage] = [
        "bananas" : UIImage(named: "bananas")!,
        "poison" : UIImage(named: "poison")!,
        "heart" : UIImage(named: "heart.png")!,
        "astroid" : UIImage(named: "astroid")!,
        "lo" : UIImage(named: "lo")!
    ]
    
    var astroidWeightArray: [Int] = [
        10,
        5,
        1,
        5,
        4
    ]
    
    var astroidNameArray:[String] = ["bananas", "poison", "heart", "astroid", "lo"]

    var newWeighedAstriodArray: [String] = []
    
    // objects generation speed
    var fallTempo = 1.0
    
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
    let astroidsCategory:UInt32 = 0x1 << 1
    let smallDogCategory:UInt32 = 0x1 << 2
    let gameBorderCategory:UInt32 = 0x1 << 3
    
    
    func spawnObjects() {

        
        // randomize which object to appear
        
        let randomIndex = Int(arc4random_uniform(UInt32(newWeighedAstriodArray.count)))
        


        let sprite = SKSpriteNode(imageNamed: String(newWeighedAstriodArray[randomIndex]))
        
        // assign a name for easier logic handling later
        sprite.name = String(newWeighedAstriodArray[randomIndex])
        
        // for collision
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody?.categoryBitMask = astroidsCategory
        sprite.physicsBody?.contactTestBitMask = smallDogCategory
        // sprite.physicsBody?.collisionBitMask = smallDogCategory
        
        // immune from collision actions
        sprite.physicsBody?.dynamic = true

        
        // calculate the horizontial position wft screen width and marginal buffer value
        let posX = Int(arc4random_uniform(UInt32(self.frame.size.width-700)))+300
        
        sprite.xScale = 0.3
        sprite.yScale = 0.3
        sprite.position = CGPoint(x: CGFloat(posX), y: ((self.frame.size.height)-150))
        
        //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        let a = SKAction.moveToY(-100.00, duration: 2)
        
        
        self.addChild(sprite)
        
        sprite.runAction(SKAction.repeatActionForever(a))
        
    }
    
    /* Almost like Init() */
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // enable physics
        self.physicsWorld.contactDelegate = self

        /* set timer */
        _ = NSTimer.scheduledTimerWithTimeInterval(fallTempo, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        
        /* Preparing weighted Array */

        for j in 0 ... astroidWeightArray.count-1 {
            for _ in 0 ... astroidWeightArray[j]-1 {

                newWeighedAstriodArray.append(String(astroidNameArray[j]))
            }

        }
        
        print(newWeighedAstriodArray)
        
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
        gameBorder.physicsBody?.contactTestBitMask = astroidsCategory
        
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
        
        if (firstBody.isEqual(tmpBody)) {
            // do nothing? cause this one has touched before
            
        } else {

            print((firstBody.node?.name)! + " touched " + (secondBody.node?.name)! +  " ")
            if secondBody.node?.name == "smallDog" {
                
                /* For heart counting */
                if (firstBody.isEqual(tmpBody1)) {
                    // do nothing? cause this one has touched HEART before
                } else {
                
                if firstBody.node?.name == "poison" {
                    if heartLeft >= 0 {
                        
                        var tmpNode = SKNode()
                        tmpNode = self.childNodeWithName("heartScore" + String(heartLeft))!
                        var tmpNodeArray: [SKNode] = []
                        tmpNodeArray.append(tmpNode)
                        self.removeChildrenInArray(tmpNodeArray)
                        tmpBody1 = firstBody
                    
                        heartLeft--
                    } else {
                        viewController.labelDie.hidden = false
                    }
                    print(heartLeft)
                } else if firstBody.node?.name == "lo" {
                    viewController.labelDie.hidden = false
                    
                } else if firstBody.node?.name == "bananas" {
                    score++
                    viewController!.updateScore(score)
                }
                    
                
                }
            } else if secondBody.node?.name == "gameBorder" {
                var tmpNode = SKNode()
                tmpNode = (firstBody.node)!
                tmpNode.removeChildrenInArray([tmpNode])
                tmpNode.removeFromParent()

            }
            

            
        }
        
        
        if firstBody.categoryBitMask==0 && secondBody.categoryBitMask==1 {
//
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

    }
}
