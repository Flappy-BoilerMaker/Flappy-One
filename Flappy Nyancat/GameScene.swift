//
//  GameScene.swift
//  Flappy Nyancat
//
//  Created by Frank Hu on 2017/2/21.
//  Copyright © 2017年 Weichu Hu. All rights reserved.
//
import Foundation
import SpriteKit
import AVFoundation
import Social
import UIKit
import Firebase

//import GameplayKit

struct GameObjects {
    static let Octocat : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameRoomTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    var items: [Score] = []
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let tmp = self.items[indexPath.row]
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        //Score print format add by Frank
        cell.textLabel?.font = UIFont(name: "Savior1", size: 30)
        if (tmp.score! < 100) {
            if (tmp.score! < 10) {
                cell.textLabel?.text = "\(indexPath.row + 1):   \(tmp.score!) stars   \(tmp.name!)"
            }
            else {
                cell.textLabel?.text = "\(indexPath.row + 1):  \(tmp.score!) stars   \(tmp.name!)"
            }
            
        }
        else {
            cell.textLabel?.text = "\(indexPath.row + 1): \(tmp.score!) stars   \(tmp.name!)"
        }
        
        //cell.textLabel?.text = "\(indexPath.row + 1). Score: \(tmp.score!)   by \(tmp.name!)"
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Scoreboard"
    }
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
    var restart = SKSpriteNode(	)
    var fb = SKSpriteNode()
    var uploading: Bool = false
    var fillin = UITextField()
    var uploader = SKSpriteNode()
    var scoreboard = GameRoomTableView()
    var yes = SKSpriteNode()
    var no = SKSpriteNode()
    var ref:FIRDatabaseReference?
    var scores: [Score]! = []
    
    // Sound Effects
    var playerBG = AVAudioPlayer()
    var playerJP = AVAudioPlayer()
    var playerStop = AVAudioPlayer()
    var playerBtnPush = AVAudioPlayer()
    var playerUploadTrue = AVAudioPlayer()
    var playerUploadFalse = AVAudioPlayer()
    var playerRestart = AVAudioPlayer()
    var playerLevelup = AVAudioPlayer()
    
    
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
        
        do {
            playerBtnPush = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Push_Btn", ofType: "mp3")!))
            playerStop.prepareToPlay()
        } catch let error {
            print(error)
        }
        
        do {
            playerUploadTrue = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "upload_true", ofType: "mp3")!))
            playerStop.prepareToPlay()
        } catch let error {
            print(error)
        }
        
        do {
            playerUploadFalse = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "upload_false", ofType: "mp3")!))
            playerStop.prepareToPlay()
        } catch let error {
            print(error)
        }
        
        do {
            playerRestart = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "restart", ofType: "mp3")!))
            playerStop.prepareToPlay()
        } catch let error {
            print(error)
        }
        
        do {
            playerLevelup = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "levelup", ofType: "mp3")!))
            playerStop.prepareToPlay()
        } catch let error {
            print(error)
        }
    }
    
    func restartScene(){
        self.playerRestart.play()
        
        self.removeAllChildren()
        self.removeAllActions()
        self.scoreboard.removeFromSuperview()
        if uploading == true {
            cancelUpload()
        }
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
        
        scoreLb.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5 + 8)
        scoreLb.text = "Star(s): \(score)"
//        scoreLb.fontName = "04b"
//        scoreLb.fontSize = 25
        scoreLb.fontName = "3Dventure"
        scoreLb.fontSize = 45
        scoreLb.zPosition = 5
        
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
        Octocat = SKSpriteNode(imageNamed: "Frank_icon_double")
        Octocat.size = CGSize(width: 45, height: 45)
        Octocat.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
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
        restart.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 50)
        restart.zPosition = 6
        restart.setScale(0)
        self.addChild(restart)
        restart.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    func share(){
        //self.playerBtnPush.play()
        
        fb = SKSpriteNode(imageNamed: "share_fix")
        
        fb.size = CGSize(width: 200, height: 100)
        fb.position = CGPoint(x: self.frame.width / 2 + 80, y: self.frame.height / 2 - 150)
        fb.zPosition = 6
        fb.setScale(0)
        self.addChild(fb)
        fb.run(SKAction.scale(to: 0.7, duration: 0.3))
        
    }
    
    //heng li upload btn
    func uploadBtn() {
        //self.playerBtnPush.play()
        
        uploader = SKSpriteNode(imageNamed: "upload_fix")
        
        uploader.size = CGSize(width: 200, height: 100)
        uploader.position = CGPoint(x: self.frame.width / 2 - 80, y: self.frame.height / 2 - 150)
        uploader.zPosition = 6
        uploader.setScale(0)
        self.addChild(uploader)
        uploader.run(SKAction.scale(to: 0.7, duration: 0.3))
    }
    
    func onUpload() {
        self.playerBtnPush.play()
        //self.playerBG.stop()
        
        //uploader.removeFromParent()
        
        fillin.frame = CGRect(x: self.frame.width / 2 - 80, y: self.frame.height / 2 - 15, width: 160, height: 30)
        fillin.placeholder = "Enter nick name"
        fillin.backgroundColor = UIColor.gray
        self.scene?.view?.addSubview(fillin)
        
        yes = SKSpriteNode(imageNamed: "check_icon")
        yes.size = CGSize(width: 50, height: 50)
        yes.position = CGPoint(x: self.frame.width / 2 + 35, y: self.frame.height / 2 - 45)
        yes.zPosition = 10
        yes.setScale(0)
        self.addChild(yes)
        yes.run(SKAction.scale(to: 1.0, duration: 0.3))
        
        no = SKSpriteNode(imageNamed: "cross_icon")
        no.size = CGSize(width: 50, height: 50)
        no.position = CGPoint(x: self.frame.width / 2 - 35, y: self.frame.height / 2 - 45)
        no.zPosition = 10
        no.setScale(0)
        self.addChild(no)
        no.run(SKAction.scale(to: 1.0, duration: 0.3))
        
        uploading = true
    }
    
    func cancelUpload() {
        self.playerBtnPush.play()
        yes.removeFromParent()
        no.removeFromParent()
        fillin.removeFromSuperview()
//        uploader.removeFromParent()
//        uploadBtn()
        fillin.text = ""
        
        uploading = false
    }
    
    func insertBoard(new: Int) {
        var swap: Int = 10
        for index in 0...9 {
//            print("Swap3: \(index)")
            if score >= self.scoreboard.items[index].score! {
                swap = index
                break
//                print("Swap1: \(swap)")
            }
        }
        if swap != 10 {
            if swap < 9 {
                for index in 0...8-swap {
//                    print("Swap2: \(3-index)")
                    self.scoreboard.items[9-index].name = self.scoreboard.items[8-index].name
                    self.scoreboard.items[9-index].score = self.scoreboard.items[8-index].score
                }
            }
            self.scoreboard.items[swap].name = fillin.text
            self.scoreboard.items[swap].score = score
            self.scoreboard.reloadData()
        }
    }
    
    func uploadScore() {
        if fillin.text != "" {
            self.playerUploadTrue.play()
            ref = FIRDatabase.database().reference()
            let post = ["name": fillin.text!,
                        "score": score] as [String : Any]
            ref?.child("Score").childByAutoId().setValue(post)
            if score > self.scoreboard.items[4].score! {
                insertBoard(new: score)
            }
            cancelUpload()
        } else {
            self.playerUploadFalse.play()
            fillin.placeholder = "Cannot be empty"
        }
    }
    
    func displayScore(){

        ref = FIRDatabase.database().reference()
        ref?.child("Score").queryOrdered(byChild: "score").queryLimited(toLast: 10).observe(.childAdded, with: { snapshot in
            let dict = snapshot.value as! [String: Any]
            let name = dict["name"] as? String
            let score = dict["score"] as? Int
//            print("test \(name!) and \(score!)")
            let tmp = Score(player: name!, score: score!)
            self.scores.append(tmp)
            if self.scores.count == 10 {
                self.scoreboard.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                self.scoreboard.frame = CGRect(x: self.frame.width / 2 - (300/2), y: (self.frame.height / 2) - (self.frame.height / 2.5) + 8, width: 300, height: 250)
                self.scoreboard.backgroundColor = UIColor(white: 1, alpha: 0.5)
                self.scene?.view?.addSubview(self.scoreboard)
                self.scores.reverse()
                self.scoreboard.items = self.scores
                self.scoreboard.reloadData()
                
            }
        })
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        
        if firstBody.categoryBitMask == GameObjects.Score && secondBody.categoryBitMask == GameObjects.Octocat{
            
            score += 1
            scoreLb.text = "Star(s): \(score)"
            if (score % 50 == 0){
                self.playerLevelup.play()
            }
            firstBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == GameObjects.Octocat && secondBody.categoryBitMask == GameObjects.Score {
            
            score += 1
            if (score % 50 == 0){
                self.playerLevelup.play()
            }
            scoreLb.text = "Star(s): \(score)"
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
                share()
                uploadBtn()
                scores = []
                displayScore()
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
                share()
                uploadBtn()
                scores = []
                displayScore()
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
        
        
        let randomPosition = CGFloat.random(min: -120, max: 220)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveRemove)
        
        self.addChild(wallPair)
    }
    
    
    func shareScore(scene: SKScene) {
        let postText: String = "I collected \(score) stars in Jump! Jump! Frank! Come and beat me in the game!\nhttps://appsto.re/us/jvKeib.i"
        let postImage: UIImage = getScreenshot(scene: scene)
        let activityItems = [postText, postImage] as [Any]
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        let controller: UIViewController = scene.view!.window!.rootViewController!
        
        controller.present(
            activityController,
            animated: true,
            completion: nil
        )
    }
    
    func getScreenshot(scene: SKScene) -> UIImage {
//        let snapshotView = scene.view!.snapshotView(afterScreenUpdates: true)
//        let bounds = UIScreen.main.bounds
//        
//        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
//        
//        snapshotView?.drawHierarchy(in: bounds, afterScreenUpdates: true)
//        
//        let screenshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        
//        UIGraphicsEndImageContext()
        //UIImageWriteToSavedPhotosAlbum(screenshotImage, nil, nil, nil)

        UIGraphicsBeginImageContextWithOptions(self.view!.bounds.size, false, 1)
        self.view?.drawHierarchy(in: (self.view?.bounds)!, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
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
            Octocat.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        }
        else{
        
            if died == true{
                
            }
            else{
                playerJP.play()
                Octocat.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Octocat.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
            }
        }

        for touch in touches{
            let location = touch.location(in: self)
        
            if died == true{
                if restart.contains(location){
                
    //              uploader.removeFromParent()
                    if uploading == true {
                        if yes.contains(location){
                            uploadScore()
                        }
                        if no.contains(location){
                            cancelUpload()
                        }
                    } else {restartScene()}
                }
                if fb.contains(location){
                    self.playerBtnPush.play()
                    shareScore(scene: self)
                }
                if uploader.contains(location){
                    if uploading == false {
                        onUpload()
                    } else {
                        
                    }
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
