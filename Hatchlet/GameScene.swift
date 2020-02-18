//
//  GameScene.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//
//****************************
// New Layout:
// Main Menu                HUD                 EndGame                 MainMenu
import Foundation
import SpriteKit

var gameOver: Bool = true
let Constant = SKTextureAtlas(named: "Constant")

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreNum: Int! = 0
    
    let menu: Menu
    let settings: Settings
    let shop: Shop
    let crown: Crown
    var endScreen: EndScreen
    
    var airEmitter: SKNode! = nil
    let emitter:Emitters
    let player:Player
    var eagle:Eagle
    var fox:Fox
    var HUD:gameHUD
    let cameraNode: SKCameraNode
    
    let Game = SKTextureAtlas(named: "Game")
    let MenuAtlas = SKTextureAtlas(named: "Menu")
    
    var landscapes = [Landscape]()
    
    // CONSTANTS ACROSS THE UI
    let groundHitBox: SKSpriteNode
    let background: Background
    
    var landscapeBin:SKNode
    var landscape1:Landscape
    var landscape2:Landscape
    
    var farBgBin:SKNode
    var farBg:Parallax
    var farBg1:Parallax
    
    var lastUpdateTime: TimeInterval = 0
    
    var eggCollected = false
    var gameSpeed:Double = 7
    
    var location = CGPoint.zero
    var touched:Bool = false
    
//******************************************************************************
    
    override init(size: CGSize) {
        endScreen = EndScreen(size: size, score: scoreNum)
        menu = Menu(size: size)
        settings = Settings(size: size)
        shop = Shop(size: size)
        crown = Crown(size: size)
        
        player = Player()
        eagle = Eagle()
        fox = Fox()
        cameraNode = SKCameraNode()
        HUD = gameHUD(size: size, player: player)
        emitter = Emitters(size: size)
        
        groundHitBox = SKSpriteNode(color: .clear, size: CGSize(width: size.width * 3, height: 2))

        background = Background(size: size)
        
        landscapeBin = SKNode()
        landscape1 = Landscape(size: size)
        landscape2 = Landscape(size: size)
        
        farBgBin = SKNode()
        farBg = Parallax(size: size)
        farBg1 = Parallax(size: size)
        
        super.init(size: size)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.81)
        
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//******************************************************************************
    
// ~Setup
    func setup() {
        physicsWorld.contactDelegate = self
        
        Constant.preload {
        }
        
// ~ADD Constants
        addChild(background)
        groundHitBox.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: groundHitBox.size.width, height: 1))
        groundHitBox.position = CGPoint(x: size.width/2, y: 44)
        groundHitBox.physicsBody!.isDynamic = false
        groundHitBox.physicsBody!.affectedByGravity = false
        groundHitBox.physicsBody!.categoryBitMask = PhysicsCategory.Ground
        groundHitBox.physicsBody!.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        groundHitBox.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        groundHitBox.zPosition = 10
        addChild(groundHitBox)
        
// ~ADD Emitter
        addChild(emitter)
        emitter.addEmitterOnPlayer(fileName: "airParticles", position: CGPoint(x: size.width + 10, y: size.height / 2), deleteTime: -1)

//~ADD Menu
        showMainMenu()
        
// -ADD Players
        addChild(player)
        player.position.x = size.width / 2
        player.position.y = size.height / 2
        player.zPosition = 99
        player.blink()
        
// -ADD Landscapes / Scene
        
        landscapeBin.addChild(landscape1)
        landscape2.position.x += landscape2.size.width
        landscapeBin.addChild(landscape2)
        landscapeBin.name = "landscapeBin"
        landscapeBin.position = CGPoint(x: 0, y:0)
        addChild(landscapeBin)
        
        farBgBin.addChild(farBg)
        farBg1.position.x += farBg1.size.width
        farBgBin.addChild(farBg1)
        farBgBin.name = "farBgBin"
        farBgBin.position = CGPoint(x: 0, y:0)
        addChild(farBgBin)
        
        scrollLandscapes(object: landscapeBin, speed: gameSpeed)
        scrollLandscapes(object: farBgBin, speed: gameSpeed * 10)
        farBgBin.isPaused = true
        landscapeBin.isPaused = true
        
    }
//END SETUP^^^^
    
//******************************************************************************
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
          for touch in (touches ) {
                  location = touch.location(in: self)
        }
    }
    
//******************************************************************************
    
//~TOUCHES BEGAN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        touched = true
        for touch in (touches ) {
            location = touch.location(in: self)
        }
        
        player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 145))
        
        let touch:UITouch = touches.first! as UITouch; let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        //Play Game Button
        if let name = touchedNode.name { if name == "playButton" {
            runGame()
            }
        }
        
//******************************************************************************
        //Crown Button
        if let name = touchedNode.name { if name == "crownButton" {
            showCrown()
            }
        }
        //Main Menu Button from Crown
        if let name = touchedNode.name { if name == "crownBackButton" {
            crown.delete()
            showMainMenu()
            }
        }
        
//******************************************************************************
        //Settings Button
        if let name = touchedNode.name { if name == "settingsButton" {
            showSettings()
            }
        }
        //Main Menu Button from Settings
        if let name = touchedNode.name { if name == "settingsBackButton" {
            settings.delete()
            showMainMenu()
            }
        }
        
//******************************************************************************
        
        //Shop Button
        if let name = touchedNode.name { if name == "shopButton" {
            showShop()
            }
        }
        //Main Menu Button from Shop
        if let name = touchedNode.name { if name == "shopBackButton" {
            shop.delete()
            showMainMenu()
            }
        }
        
//******************************************************************************
        
        //Main Menu Button from EndScreen
        if let name = touchedNode.name { if name == "menu" {
            mainMenu()
            }
        }
        //~ADD Player Smoke
        emitter.addEmitterOnPlayer(fileName: String("playerSmoke"), position: player.position, deleteTime: 1)
    }
    
//******************************************************************************
    
//~TOUCHES ENDED
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false
    }
    
    func setScore(eggType: String) {
        //gameSpeed is how fast the animation plays
        //this is only good for createEggs()
        
        if gameSpeed > 1.5 {
            gameSpeed *= 0.98
            //speeds up other animations by accessing their speed
            landscapeBin.action(forKey: "landscapeBinMoveLeft")!.speed += 0.025
            farBgBin.action(forKey: "farBgBinMoveLeft")!.speed += 0.012
        }

        if eggType == "GoldenEgg"
        {
            scoreNum += 3
        } else {
        scoreNum += 1
        }
        
        HUD.scoreLabel.text = String(scoreNum)
        HUD.labelShadow.text = String(scoreNum)
    }
    
//******************************************************************************
    
    func deleteEgg(egg: SKNode) {
        
        if egg.name == "GoldenEgg" {
            egg.removeAllActions()
            egg.physicsBody = nil
            
            HUD.goldenEggUpdate()

            let moveEgg = SKAction.move(to: CGPoint(x: egg.frame.size.width, y: HUD.goldenEgg.position.y), duration: 0.85)
            moveEgg.timingMode = SKActionTimingMode.easeInEaseOut
            let reset = SKAction.run() { [weak self] in guard self != nil else { return }
                           egg.isHidden=false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    egg.removeAllChildren()
                    egg.removeAllActions()
                    egg.removeFromParent()
                }
                       }
            egg.run(SKAction.sequence([moveEgg,reset]))
            
        }
        else {
            emitter.addEmitter(position: egg.position)
            egg.removeAllChildren()
            egg.removeAllActions()
            egg.removeFromParent()
        }
    }
    
//******************************************************************************
    
    func createEgg() {
        if gameOver == false {
            
            var egg: Egg
            
            if ((Int.random(in: 1...15)) == 7 ) {
                egg = Egg(isGold: true)
                let goldenEggEmitter = SKEmitterNode(fileNamed: "eggCoin")
                goldenEggEmitter?.targetNode = self.scene
                egg.addChild(goldenEggEmitter!)
            } else {
                egg = Egg()
            }
            
            let maxY = size.height - (egg.size.height * 3)
            let minY = egg.size.height + 100
            let range = maxY - minY
            let eggY = maxY - CGFloat(arc4random_uniform(UInt32 (range)))
            
            egg.position = CGPoint(x:size.width, y: eggY)
            addChild(egg)
            let moveLeft = SKAction.moveBy(x: -(size.width), y: 0, duration: gameSpeed)
                egg.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        }
    }
    
//******************************************************************************
    
    func showMenu() {
        MenuAtlas.preload{}
        addChild(menu)
    }
    
//******************************************************************************
    
    func runGame() {
        gameOver = false
    
        Game.preload{}
        
    // Add Lives
        HUD = gameHUD(size: size, player: player)
        HUD.addLife(howMany: 3)
        HUD.position.x = -(size.width / 2)
        addChild(HUD)
        
    // Remove Menu Children
        menu.removeFromParent()
        
    // Add Children:
        
    // ~ Generate Eggs
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run() { [weak self] in guard let `self` = self else { return }
                   self.createEgg()
                }, SKAction.wait(forDuration: 1)])
        ),withKey: "createEgg")
        
        farBgBin.isPaused = false
        landscapeBin.isPaused = false
    }
    
//******************************************************************************
    // Move the node to the location of the touch
    func moveNodeToLocation() {
        // Compute vector components in direction of the touch
        var dx = (location.x) - player.position.x
        // How fast to move the node. Adjust this as needed
        let speed:CGFloat = 0.08
        // Scale vector
        dx = dx * speed
        
        player.position.x = player.position.x+dx
        HUD.playerShadow.position.x = player.position.x + size.width / 2
    }
    
//******************************************************************************
    
    func mainMenu() {
        
        // Add Menu
        showMenu()
        
        // Remove Game Children
        HUD.removeAllChildren()
        HUD.removeFromParent()
        
        endScreen.removeAllChildren()
        endScreen.removeFromParent()
    }
    
//******************************************************************************
        
    func showMainMenu() {
        addChild(menu)
        menu.show()
    }
    
//******************************************************************************
    
    func showCrown() {
        menu.delete()
        
        addChild(crown)
        crown.show()
    }
    
//******************************************************************************
    
    func showSettings() {
        menu.delete()
        
        addChild(settings)
        settings.show()
    }
    
//******************************************************************************
        
    func showShop() {
        menu.delete()
        
        addChild(shop)
        shop.show()
        }
        
//******************************************************************************
    
    func endGame() {
        gameOver = true
        
        fox.stop()
        eagle.stop()
        
        // ~Add endScreen
        endScreen = EndScreen(size: size, score: scoreNum)
        addChild(endScreen)
        
        if scoreNum > UserDefaults.standard.integer(forKey: "highScore") {
            UserDefaults.standard.set(scoreNum, forKey: "highScore")
        }
        
        //Freeze Landscapes
        landscapeBin.isPaused = true
        farBgBin.isPaused = true
        landscapeBin.action(forKey: "landscapeBinMoveLeft")!.speed = 1
        farBgBin.action(forKey: "farBgBinMoveLeft")!.speed = 1
        
        //Stop spawning eggs
        removeAction(forKey: "createEgg")
        
        //delete any visisble eggs
        for child in self.children {
            if child.name == "egg" {
                deleteEgg(egg: child)
            }
            else if child.name == "GoldenEgg" {
                child.removeAllChildren()
                child.removeAllActions()
                child.removeFromParent()
            }
        }
        
        //stop any enemys
        fox.removeAllActions()
        fox.removeFromParent()
        
        //hide the game's utility & reset game score
        HUD.removeFromParent()
        HUD.scoreLabel.text = "0"
        HUD.labelShadow.text = "0"
        scoreNum = 0
 
       //reset game speed
        gameSpeed = 7
    }
    
//******************************************************************************
        
    //~UPDATE
        override func update(_ currentTime: TimeInterval) {
    
            if !gameOver {
                checkBackground()
            }
            
            if player.physicsBody!.velocity == CGVector(dx: 0, dy: 0) {
                player.removeAction(forKey: "flap")
                player.texture = player.playerImage
            }
            else {
                if let _ = player.action(forKey: "flap") {
                    // action is running
                } else {
                    player.flap()
                }
            }
            
            if (touched) {
                    moveNodeToLocation()
                }
            
            HUD.updateShadow(userOfShadow: "player", currentPos: player.position.y)
            HUD.updateShadow(userOfShadow: "fox", currentPos: fox.position.y)
            HUD.enemyShadow.position.x = (fox.position.x + size.width / 2) - 5
            
            // Spawn Enemy
            if player.physicsBody!.velocity == CGVector(dx: 0, dy: 0) &&  (gameOver == false) && (fox.isRunning() == false){
                spawnEnemy()
                fox.run(speed: gameSpeed, viewSize: size)
                }
        }
        
//******************************************************************************
        
        func spawnEnemy() {
            HUD.enemyShadow.isHidden = false
            
            fox = Fox()
            fox.position.x = size.width
            fox.position.y = groundHitBox.position.y + (fox.size.height)
            fox.zPosition = 100
            addChild(fox)
        }
    
//******************************************************************************
        
    // ~Physics
        func didBegin(_ contact: SKPhysicsContact) {
            let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if collision == PhysicsCategory.Egg | PhysicsCategory.Player {
                if contact.bodyA.categoryBitMask == PhysicsCategory.Egg {
                    setScore(eggType: contact.bodyA.node!.name!)
                    deleteEgg(egg: contact.bodyA.node!)
                }
                else {
                    setScore(eggType: contact.bodyB.node!.name!)
                    deleteEgg(egg: contact.bodyB.node!)
                }
            }
            
            if collision == PhysicsCategory.Roof | PhysicsCategory.Player {
                
                 if gameOver == false && !eagle.isRunning(){
                eagle = Eagle()
                addChild(eagle)
                eagle.run(speed: gameSpeed, viewSize: size)
                }
                emitter.addEmitterOnPlayer(fileName: "feathers", position: player.position)
            }
            
            if collision == PhysicsCategory.Ground | PhysicsCategory.Player {
                emitter.addEmitterOnPlayer(fileName: "grass", position: player.position, deleteTime: 0.4)
                if gameOver == false && !fox.isRunning(){
                    spawnEnemy()
                    fox.run(speed: gameSpeed, viewSize: size)
                }
            }
            
            if collision == PhysicsCategory.Enemy | PhysicsCategory.Ground {
                emitter.addEmitterOnPlayer(fileName: "grass", position: CGPoint(x: fox.position.x, y: fox.position.y - 15), deleteTime: 0.4)
            }
            
            //contact enemy & player
            if collision == PhysicsCategory.Player | PhysicsCategory.Enemy {
                if contact.bodyB.node!.name == "fox" || contact.bodyB.node!.name == "fox"{
                    fox.stop()
                }
                else {
                eagle.stop()
                }
                HUD.enemyShadow.isHidden = true
                 if HUD.removeLife() == false{
                               endGame()
                }
                player.hurtHead()
                emitter.addEmitterOnPlayer(fileName: "newSpark", position: player.position)
            }
        }
        
        func didEnd(_ contact: SKPhysicsContact) {
        }
        
//******************************************************************************
        
    // ~Scrolling Backgrounds
    func scrollLandscapes(object:SKNode, speed: Double, aniSpeed: CGFloat = 0.0) {
                let key = object.name! + "MoveLeft"
                let moveLeft = SKAction.moveBy(x: -(object.calculateAccumulatedFrame().size.width / 2), y: 0, duration: speed)
                let reset = SKAction.run() { [weak self] in guard self != nil else { return }
                    object.position = CGPoint(x: 0, y: 0)
                }
                object.run(SKAction.repeatForever(SKAction.sequence([moveLeft, reset])),withKey: key)
            }

//******************************************************************************
        
        // ~Update Landscapes
        func checkBackground() {
            if landscapeBin.position.x < -(size.width) {
                landscapeBin.removeAllActions()
                landscapeBin.position.x = 0
                scrollLandscapes(object: landscapeBin, speed: gameSpeed)
            }
        }
    
//******************************************************************************
}
