//
//  GameScene.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//
//****************************
// New Layout:
// Main Menu                HUD                 EndGame                 MainMenu
import Foundation
import SpriteKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

//var gameOver: Bool = true
let Constant = SKTextureAtlas(named: "Constant")
var const = Constants()

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreNum: Int! = 0
    
    let menu: Menu
    let settings: Settings
    let shop: Shop
    let crown: Crown
    var endScreen: EndScreen
    
    let tut: Tut
    
    var trailEmitter:SKEmitterNode
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
    
    var scrollingGroundBin:SKNode
    var scrollingGround:Parallax
    var scrollingGround1:Parallax
    
    var gameSpeed:Double = 7
    
    var randomMax = 26
    
    var eagleSpeed:Double = 0.007
    
    var location = CGPoint.zero
    var touched:Bool = false
    
    var isTouching = false
    var prevTouchedNode = SKNode()
    
//******************************************************************************
    
    override init(size: CGSize) {
        endScreen = EndScreen(size: size, score: scoreNum)
        menu = Menu(size: size)
        settings = Settings(size: size)
        shop = Shop(size: size)
        crown = Crown(size: size)
        tut = Tut(size:size)
        
        const = Constants()
        
        trailEmitter = SKEmitterNode()
        
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
        
        scrollingGroundBin = SKNode()
        scrollingGround = Parallax(size: size)
        scrollingGround1 = Parallax(size: size)
        
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
        player.updateCostume()
                
// -ADD Landscapes / Scene
        
        landscapeBin.addChild(landscape1)
        landscape2.position.x += landscape2.size.width
        landscapeBin.addChild(landscape2)
        landscapeBin.name = "landscapeBin"
        landscapeBin.position = CGPoint(x: 0, y:0)
        addChild(landscapeBin)
        
        scrollingGroundBin.addChild(scrollingGround)
        scrollingGround1.position.x += scrollingGround1.size.width
        scrollingGroundBin.addChild(scrollingGround1)
        scrollingGroundBin.name = "scrollingGroundBin"
        scrollingGroundBin.position = CGPoint(x: 0, y:0)
        addChild(scrollingGroundBin)
        
        scrollLandscapes(object: landscapeBin, speed: gameSpeed)
        scrollLandscapes(object: scrollingGroundBin, speed: gameSpeed * 10)
        scrollingGroundBin.isPaused = true
        landscapeBin.isPaused = true
        
        if UserDefaults.standard.integer(forKey: "highScore") == 0 {
            const.setGameTut(value: true)
        }
    }
//END SETUP^^^^
    
//******************************************************************************
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches ) {
            location = touch.location(in: self)
        }
        let touchedNode = self.atPoint(location)
        
        var touchingNode = ""
        // This will find the tochable nodes name
        for nodeName in const.touchableButtons {
            if nodeName == touchedNode.name {
                touchingNode = nodeName
                prevTouchedNode = touchedNode
            }
        }
        
        if touchingNode != "" && !isTouching {
            touchedNode.run(.scale(to: 0.80, duration: 0.2))
            isTouching = true
        } else if touchingNode == "" && prevTouchedNode.name != ""  {
            prevTouchedNode.run(.scale(to: 1, duration: 0.2))
            prevTouchedNode = SKNode()
            isTouching = false
        }
    }
    
//******************************************************************************
    
//~TOUCHES BEGAN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          for touch in (touches ) {
            location = touch.location(in: self)
        }
        touched = true
        
        if const.gameOver == false {
            player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 145))
             emitter.addEmitterOnPlayer(fileName: String("playerSmoke"), position: player.position, deleteTime: 1)
        }
        else {
            player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 15))
            let touch:UITouch = touches.first! as UITouch; let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            for nodeName in const.touchableButtons {
                if nodeName == touchedNode.name {
                    touchedNode.run(.scale(to: 0.80, duration: 0.2))
                }
            }
        }
    }
    
//******************************************************************************
    
//~TOUCHES ENDED
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false
        
        if const.gameOver {
            for touch in (touches ) {
                location = touch.location(in: self)
            }
            
            let touch:UITouch = touches.first! as UITouch; let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            switch touchedNode {
            case is GameScene:
                return
            case let touchedNode as ItemNode:
                var owned = false
                for nodeName in const.ownedItems {
                    if nodeName == touchedNode.name {
                        owned = true
                        shop.setCostume(costume: nodeName, owned: owned)
                        player.updateCostume()
                    }
                }
                if !owned && const.goldenEggs >= Int(touchedNode.priceNode.text!)! {
                    shop.setCostume(costume: touchedNode.name ?? "")
                    player.updateCostume()
                    touchedNode.setPriceText()
                }
            case is SKSpriteNode:
                for nodeName in const.touchableButtons {
                    if nodeName == touchedNode.name {
                        touchedNode.run(.scale(to: 1, duration: 0.2))
                    }
                }
            default: ()
            }
            
            switch touchedNode.name {
            case "gameDiff":
                settings.switchGameDiff()
            case "eggSwitchTutorial":
                settings.switchButton()
            case "playButton":
                runGame()
            case "leftButton":
                shop.pageBack()
            case "rightButton":
                shop.pageForward()
            case "crownButton":
                showCrown()
            case "crownBackButton":
                crown.delete()
                showMainMenu()
            case "settingsButton":
                showSettings()
            case "settingsBackButton":
                settings.delete()
                showMainMenu()
            case "shopButton":
                showShop()
            case "shopBackButton":
                shop.delete()
                showMainMenu()
            case "menu":
                mainMenu()
            default: ()
            }

        }
    }
    
    func setScore(eggType: String) {
        
        if gameSpeed > 1.8 {
            gameSpeed *= 0.989
            eagleSpeed /= 0.99
            //speeds up other animations by accessing their speed
            landscapeBin.action(forKey: "landscapeBinMoveLeft")!.speed += 0.017
            scrollingGroundBin.action(forKey: "scrollingGroundBinMoveLeft")!.speed += 0.010
            
            //emitter.updateSpeed()
        }
        
        if scoreNum >= 2 {
            tut.delete()
        }

        if eggType == "GoldenEgg" {
            const.goldenEggs += 1
            UserDefaults.standard.set(const.goldenEggs, forKey: "goldenEggs")
        } else {
        scoreNum += 1
        }
        
        HUD.scoreLabel.text = String(scoreNum)
        HUD.labelShadow.text = String(scoreNum)
       
        if const.gameDifficulty != 0 {
            if scoreNum % 15 == 1 && randomMax >= 7 {
                randomMax -= 1
            }
            let random = (Int.random(in: 1...randomMax))
            if ( random == 7 ) {
                randomEnemy()
            }
        }
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
                    egg.removeFromParent()
                }
                       }
            egg.run(SKAction.sequence([moveEgg,reset]))
            
        }
        else {
            emitter.addEmitter(position: egg.position)
            egg.removeAllChildren()
            egg.removeFromParent()
        }
    }
    
//******************************************************************************
    
    func createEgg() {
        if const.gameOver == false {
            
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
        Game.preload{}
        
        const.gameOver = false
        player.removeHome()
        //trail()
        
        if const.gameTutorialOn {
            addChild(tut)
            tut.position = CGPoint(x: 0, y: -size.width / 1.5)
            tut.show()
        }

        emitter.addEmitter(position: player.position)
    
    // Add Lives
        HUD = gameHUD(size: size, player: player)
        HUD.addLife(howMany: 3)
        HUD.position.x = -(size.width / 2)
        addChild(HUD)
        
    // Remove Menu Children
        menu.removeFromParent()
        
    // ~ Generate Eggs
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run() { [weak self] in guard let `self` = self else { return }
                   self.createEgg()
                }, SKAction.wait(forDuration: createEggGameMode())])
        ),withKey: "createEgg")
        
        scrollingGroundBin.isPaused = false
        landscapeBin.isPaused = false
        
        randomMax = 26
        
        if const.gameDifficulty == 0 {
            eagleSpeed = 0.0005
        }
        else if const.gameDifficulty == 1 {
            eagleSpeed = 0.007
        }
        else {
            eagleSpeed = 0.01
        }
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
        menu.playButton.removeAllActions()
        menu.show()
    }
    
    func trail() {
        trailEmitter = SKEmitterNode(fileNamed: "trailTest")!
        trailEmitter.targetNode = self.scene
        trailEmitter.position.x = -(player.size.width/2.3)
        trailEmitter.position.y = 0
        trailEmitter.zPosition = player.zPosition + 1
        player.addChild(trailEmitter)
        print("added TRAIL")
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
        // ~Reset Game Stuff
        const.gameOver = true
        player.addHome()
        gameSpeed = 7
        emitter.resetSpeed()
       
        // ~Delete Game Stuff
        HUD.removeFromParent()
        HUD.scoreLabel.text = "0"
        HUD.labelShadow.text = "0"
        tut.delete()
        fox.stop()
        eagle.stop()
        removeAction(forKey: "createEgg") //Stop spawning eggs
        
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
        
        if scoreNum > UserDefaults.standard.integer(forKey: "highScore") {
            UserDefaults.standard.set(scoreNum, forKey: "highScore")
        }
        if scoreNum >= 10 {
                   const.setGameTut(value: false)
        }
        
        //Freeze Landscapes
        landscapeBin.isPaused = true
        scrollingGroundBin.isPaused = true
        landscapeBin.action(forKey: "landscapeBinMoveLeft")!.speed = 1
        scrollingGroundBin.action(forKey: "scrollingGroundBinMoveLeft")!.speed = 1
 
        // ~Add endScreen
        endScreen = EndScreen(size: size, score: scoreNum)
        addChild(endScreen)
        
        scoreNum = 0
    }
    
//******************************************************************************
        
    //~UPDATE
        override func update(_ currentTime: CFTimeInterval) {
            if !const.gameOver {
                checkBackground()
            }
            
            if eagle.isRunning() {
                moveCloser()
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
            
            if fox.isRunning() {
                 HUD.updateShadow(userOfShadow: "fox", currentPos: fox.position.y)
                  HUD.enemyShadow.position.x = (fox.position.x + size.width / 2) - 5
            }
            
            // Spawn Enemy
            if player.physicsBody!.velocity == CGVector(dx: 0, dy: 0) &&  (const.gameOver == false) && (fox.isRunning() == false) && scoreNum > 0 && const.gameDifficulty != 0{
                spawnEnemy()
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
            
            fox.run(speed: gameSpeed, viewSize: size)
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
                
                 if const.gameOver == false && !eagle.isRunning(){
                    eagle = Eagle()
                    eagle.position.x = size.width + eagle.size.width
                    eagle.position.y = size.height / 2
                    addChild(eagle)
                    eagle.run(speed: gameSpeed, viewSize: size)
                }
                emitter.addEmitterOnPlayer(fileName: "feathers", position: player.position)
            }
            
            if collision == PhysicsCategory.Ground | PhysicsCategory.Player {
                emitter.addEmitterOnPlayer(fileName: "grass", position: player.position, deleteTime: 0.4)
                if const.gameOver == false && !fox.isRunning() && scoreNum >= 1{
                    spawnEnemy()
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
    
    func moveCloser() {
        let distance = player.position.y - eagle.position.y
        
        if eagle.position.x > size.width / 2 {
            eagle.position.y += distance * CGFloat(eagleSpeed)
            //print(distance * 0.048)
        }
    }
    
//******************************************************************************
        
    func randomEnemy() {
        
        let random = (Int.random(in: 1...2))
        
        if const.gameOver == false {
            if (random == 1 && !eagle.isRunning())
             {
                eagle = Eagle()
                eagle.position.x = size.width + eagle.size.width
                eagle.position.y = size.height / 2
                addChild(eagle)
                eagle.run(speed: gameSpeed, viewSize: size)
            }
            else if random == 2 && !fox.isRunning() {
                spawnEnemy()
            }
            else if !eagle.isRunning() {
                eagle = Eagle()
                eagle.position.x = size.width + eagle.size.width
                eagle.position.y = size.height / 2
                addChild(eagle)
                eagle.run(speed: gameSpeed, viewSize: size)
            }
            else if !fox.isRunning() {
                spawnEnemy()
            }
        }
    }
        
    func createEggGameMode() -> Double {
        var eggSpawnRate = 0.0
        if const.gameDifficulty == 0 {
            eggSpawnRate = 0.8
        }
        else if const.gameDifficulty == 1 {
            eggSpawnRate = 1
        }
        else {
           eggSpawnRate =  0.25
        }
        return eggSpawnRate
    }
    
    //******************************************************************************
    

    
};
