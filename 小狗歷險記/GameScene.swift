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


// Class defining Game Level Details
class GameLevelDetails {
    var level:Int = 1
    var spawnInterval:NSTimeInterval = 0.0
    var gravity:CGVector = CGVectorMake(0.0, -0.5)
    var scoreNeededforNextLevel:Int = 0
    var gameBackgroundName = "background1.png"
    
    init(levelNumber: Int, objectSpawnInterval: NSTimeInterval, gravity: CGVector, scoreNeededforNextLevel: Int, backgroundImageName: String) {
        self.level = levelNumber
        self.spawnInterval = objectSpawnInterval
        self.gravity = gravity
        self.scoreNeededforNextLevel = scoreNeededforNextLevel
        self.gameBackgroundName = backgroundImageName
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameStatus: Bool = false
    
    var smallDogSprite: SKSpriteNode!
    
    var backgroundSprite: SKSpriteNode! = nil
    
    var objectsArray: [String:UIImage] = [
        "bananas" : UIImage(named: "bananas")!,
        "cherry" : UIImage(named: "cherry.png")!,
        "orange" : UIImage(named: "orange.png")!,
        "poison" : UIImage(named: "poison")!,
        "heart" : UIImage(named: "heart.png")!,
        "astroid1" : UIImage(named: "astroid1")!,
        "lo" : UIImage(named: "lo")!
    ]
    
    var objectsWeightArray: [Int] = [
        10,
        10,
        10,
        2,
        1,
        5,
        1
    ]
    
    var objectsNameArray:[String] = ["bananas", "cherry", "orange", "poison", "heart", "astroid1", "lo"]

    var newWeighedObjectsArray: [String] = []
    
    // objects generation Interval
    var generationInterval:NSTimeInterval = NSTimeInterval(1.5)
    
    // small dog movement velocity
    var hVel = 250.0
    
    // g for objects to fall
    var gVel = 250.0
    
    // gtimer
    var spawnMachine : NSTimer = NSTimer()
    var gameTimer : NSTimer = NSTimer()
    
    // game level

    var gLevelCheckInterval:NSTimeInterval = NSTimeInterval(0.5)
    var gCurrentGameObj:GameLevelDetails = GameLevelDetails(levelNumber: 0, objectSpawnInterval: 0.0, gravity: CGVector(dx: 0.0, dy: 0.0), scoreNeededforNextLevel: 0, backgroundImageName: "background1.png")
    var allGameLevelObj:[GameLevelDetails] = []
    
    // score
    var gscore: Int = 0
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
    let backgroundImageCategory:UInt32 = 0x1 << 4
    
    func changeBackgroundImage(imageName: String) // Change background image
    {

        let background = SKSpriteNode(imageNamed: imageName)
        background.name = "background"
            
        // self.viewController?.view.sizeToFit()
        background.size = self.size
        background.position.x = self.size.width/2
        background.position.y = self.size.height/2
        background.zPosition = -1
        backgroundSprite = background
            
        self.addChild(background)
        

    }
    
    
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


        }
    }
    
    
    // spawning new falling objects
    func spawnObjects() {
        self.viewController?.viewSub
        
        // randomize which object to appear
        
        let randomIndex = Int(arc4random_uniform(UInt32(newWeighedObjectsArray.count)))
        

        let sprite = SKSpriteNode(imageNamed: String(newWeighedObjectsArray[randomIndex]))
        
        // assign a name for easier logic handling later
        sprite.name = String(newWeighedObjectsArray[randomIndex])
        
        // for collision
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        
        if (gCurrentGameObj.level > 4 || sprite.name == "astroid1") { /* applies to astriods and higher level objects only */
            sprite.physicsBody?.dynamic = true
            sprite.physicsBody?.allowsRotation = true
            sprite.physicsBody?.density = 10
        }
        
        sprite.physicsBody?.categoryBitMask = objectsCategory
        sprite.physicsBody?.contactTestBitMask = smallDogCategory
        // sprite.physicsBody?.collisionBitMask = smallDogCategory
        
        // immune from collision actions
        sprite.physicsBody?.dynamic = true

        
        // calculate the horizontial position wft screen width and marginal buffer value
        let posX = Int(arc4random_uniform(UInt32(self.frame.size.width)-75))+30
        
        sprite.xScale = 0.3
        sprite.yScale = 0.3
        sprite.position = CGPoint(x: CGFloat(posX), y: ((self.frame.size.height)-150))
    
        if sprite.position.x > 300 || sprite.position.x < 30 {
        print(sprite.position.x)
        }
        
        self.addChild(sprite)

        
    }
    
    /* Almost like Init() */
    override func didMoveToView(view: SKView) {
        
        
        /* Setup your scene here */
        
        // start the game
        gameStatus = true

        // Initilizing Game Levels
        allGameLevelObj = [
            GameLevelDetails(levelNumber: 1, objectSpawnInterval: NSTimeInterval(1.5), gravity: CGVectorMake(0, -2.0), scoreNeededforNextLevel: 10, backgroundImageName: "background1.png"),
            
            GameLevelDetails(levelNumber: 2, objectSpawnInterval: NSTimeInterval(1.3), gravity: CGVectorMake(0, -3.5), scoreNeededforNextLevel: 20, backgroundImageName: "background2.png"),
            
            GameLevelDetails(levelNumber: 3, objectSpawnInterval: NSTimeInterval(1.0), gravity: CGVectorMake(0, -4.0), scoreNeededforNextLevel: 30, backgroundImageName: "background3.png"),
            
            GameLevelDetails(levelNumber: 4, objectSpawnInterval: NSTimeInterval(0.8), gravity: CGVectorMake(0, -5.0), scoreNeededforNextLevel: 40, backgroundImageName: "background4.png"),
            
            GameLevelDetails(levelNumber: 5, objectSpawnInterval: NSTimeInterval(0.6), gravity: CGVectorMake(0, -7.0), scoreNeededforNextLevel: 50, backgroundImageName: "background5.png"),
            
            GameLevelDetails(levelNumber: 6, objectSpawnInterval: NSTimeInterval(0.2), gravity: CGVectorMake(0, -10.0), scoreNeededforNextLevel: 60, backgroundImageName: "background6.png"),
            
            GameLevelDetails(levelNumber: 7, objectSpawnInterval: NSTimeInterval(0.1), gravity: CGVectorMake(0, -20.0), scoreNeededforNextLevel: 100, backgroundImageName: "background6.png")  /* Level dummy */
        
        ]
        
        gCurrentGameObj = allGameLevelObj[0]
        
        
        // enable physics
        self.physicsWorld.contactDelegate = self
        physicsWorld.gravity = gCurrentGameObj.gravity
        
        // update background image
        changeBackgroundImage("background1.png")
        
        
        /* set timer and objects spawn */
        spawnMachine = NSTimer.scheduledTimerWithTimeInterval(generationInterval, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(gLevelCheckInterval, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        
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
            heartScoreSprite.position.x = 90 + CGFloat(i * 50)  /*   next is 185 */
            heartScoreSprite.position.y = 610
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
        smallDogSprite.position.x = self.frame.width/2
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
                    case "astroid1"?:
                        /* Just bounce off */
                        tmpBody1 = firstBody

                    default:
                        tmpBody1 = firstBody
                        removeSprite (firstBody)
                        
                        gscore++
                        viewController!.updateScore(gscore)
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
        viewController.labelLevel.text = "Level: " + String(gCurrentGameObj.level)
        
        spawnMachine = NSTimer.scheduledTimerWithTimeInterval(t, target: self, selector: Selector("spawnObjects"), userInfo: nil, repeats: true)
        
    }
    
    func updateTimer() {
        
        // check if this is time to to update Levels
        if (gCurrentGameObj.scoreNeededforNextLevel == gscore) && (gCurrentGameObj.level >= 1) {
            physicsWorld.gravity = gCurrentGameObj.gravity
            gCurrentGameObj = allGameLevelObj[gCurrentGameObj.level] /* level Index + 1 */
            
            changeBackgroundImage(gCurrentGameObj.gameBackgroundName)

            levelIncrement(gCurrentGameObj.spawnInterval)
        }
        
        

    }
   

}
