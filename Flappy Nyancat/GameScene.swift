//
//  GameScene.swift
//  Flappy Nyancat
//
//  Created by Frank Hu on 2017/2/21.
//  Copyright © 2017年 Weichu Hu. All rights reserved.
//

import SpriteKit
import AVFoundation
//import GameplayKit

struct GameObjects {
    static let Octocat : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var entities = [GKEntity]()
    //var graphs = [String : GKGraph]()
    
    var Ground = SKSpriteNode()
    var Octocat = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveRemove = SKAction()
    var gameStart = Bool()
    
    var score = Int()
    let scoreLb = SKLabelNode()
    
    var died = Bool()
    var restart = SKSpriteNode()
    
    var playerBG = AVAudioPlayer()
    var playerJP = AVAudioPlayer()
    var playerStop = AVAudioPlayer()
    
    
    //private var lastUpdateTime : TimeInterval = 0
    //private var label : SKLabelNode?
    //private var spinnyNode : SKShapeNode?
    
    func playSound() {
        
        do {
            playerBG = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "NyanCat", ofType: "mp3")!))
            playerBG.prepareToPlay()
        } catch let error {
            print(error)
        }
        
        do {
            playerJP = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "jump", ofType: "wav")!))
            playerJP.prepareToPlay()
        } catch let error {
            print(error)
        }
        
        do {
            playerStop = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "stop_cut", ofType: "mp3")!))
            playerStop.prepareToPlay()
        } catch let error {
            print(error)
        }
    }
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStart = false
        score = 0
        createScene()
        
    }
    
    
    func createScene() {
        
        //print(UIFont.familyNames)
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "pixel_background")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        
        scoreLb.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLb.text = "Star(s):\(score)"
        scoreLb.fontName = "04b"
        scoreLb.zPosition = 5
        scoreLb.fontSize = 25
        //scoreLb.fontColor
        self.addChild(scoreLb)
        
        //set up ground image
        Ground = SKSpriteNode(imageNamed: "pixel_keyboard")
        Ground.setScale(0.42)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = GameObjects.Ground
        Ground.physicsBody?.collisionBitMask = GameObjects.Octocat
        Ground.physicsBody?.contactTestBitMask = GameObjects.Octocat
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        self.addChild(Ground)
        
        //set up octocat image
        Octocat = SKSpriteNode(imageNamed: "Nyancat")
        Octocat.size = CGSize(width: 50, height: 30)
        Octocat.position = CGPoint(x: self.frame.width / 2 - Octocat.frame.width, y: self.frame.height / 2)
        
        Octocat.physicsBody = SKPhysicsBody(circleOfRadius: Octocat.frame.height / 2)
        Octocat.physicsBody?.categoryBitMask = GameObjects.Octocat
        Octocat.physicsBody?.collisionBitMask = GameObjects.Ground | GameObjects.Wall
        Octocat.physicsBody?.contactTestBitMask = GameObjects.Ground | GameObjects.Wall | GameObjects.Score
        Octocat.physicsBody?.affectedByGravity = false
        Octocat.physicsBody?.isDynamic = true
        
        Octocat.zPosition = 2
        self.addChild(Octocat)
        
    }
    
    override func didMove(to view: SKView) {
        playSound()
        createScene()
    }
    
    func createBTN(){
        self.playerStop.play()
        self.playerBG.stop()
        
        restart = SKSpriteNode(imageNamed: "Restart")
        restart.size = CGSize(width: 200, height: 100)
        restart.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restart.zPosition = 6
        restart.setScale(0)
        self.addChild(restart)
        restart.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        
        if firstBody.categoryBitMask == GameObjects.Score && secondBody.categoryBitMask == GameObjects.Octocat{
            
            score += 1
            scoreLb.text = "GitHub Star(s):\(score)"
            firstBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == GameObjects.Octocat && secondBody.categoryBitMask == GameObjects.Score {
            
            score += 1
            scoreLb.text = "GitHub Star(s):\(score)"
            secondBody.node?.removeFromParent()
            
        }
            
        else if firstBody.categoryBitMask == GameObjects.Octocat && secondBody.categoryBitMask == GameObjects.Wall || firstBody.categoryBitMask == GameObjects.Wall && secondBody.categoryBitMask == GameObjects.Octocat{
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
        }
        else if firstBody.categoryBitMask == GameObjects.Octocat && secondBody.categoryBitMask == GameObjects.Ground || firstBody.categoryBitMask == GameObjects.Ground && secondBody.categoryBitMask == GameObjects.Octocat{
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
        }
    }
    
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "star_05")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = GameObjects.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = GameObjects.Octocat
        scoreNode.color = SKColor.blue
        
        
        wallPair = SKNode()
        //let wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "top_wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall_Redbull_02")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = GameObjects.Wall
        topWall.physicsBody?.collisionBitMask = GameObjects.Octocat
        topWall.physicsBody?.contactTestBitMask = GameObjects.Octocat
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = GameObjects.Wall
        btmWall.physicsBody?.collisionBitMask = GameObjects.Octocat
        btmWall.physicsBody?.contactTestBitMask = GameObjects.Octocat
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        //topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveRemove)
        
        self.addChild(wallPair)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStart == false{
            
            gameStart =  true
            
            self.playerBG.play()
            
            self.Octocat.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveRemove = SKAction.sequence([movePipes, removePipes])
            
            playerJP.play()
            Octocat.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Octocat.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 18))
        }
        else{
            
            if died == true{
                
            }
            else{
                playerJP.play()
                Octocat.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Octocat.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 18))
            }
            
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            
            if died == true{
                if restart.contains(location){
                    restartScene()
                    
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStart == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                        
                    }
                    
                }))
                
            }
        }
    }
}
