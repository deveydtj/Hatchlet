//
//  GameLogic.swift
//  Hatchlet
//
//  Created by jake on 5/17/25.
//  Copyright © 2025 Jacob DeVeydt. All rights reserved.
//
//  Handles core game flow: menus, spawning, scoring, and state transitions.
//

import SpriteKit

class GameLogic {
    private weak var scene: GameScene?
    
    // Object pools for performance optimization
    private var eggPool: [Egg] = []
    private var goldEggPool: [Egg] = []
    private var foxPool: [Fox] = []
    private var eaglePool: [Eagle] = []
    private let maxPoolSize = 10

    init(scene: GameScene) {
        self.scene = scene
    }

    /// Initial scene setup (moved from GameScene.setup())
    func setup() {
        guard let s = scene else { return }
        s.physicsWorld.contactDelegate = s
        
        // Preload all texture atlases at once for better performance
        let preloadGroup = DispatchGroup()
        
        preloadGroup.enter()
        Constant.preload { preloadGroup.leave() }
        
        preloadGroup.enter()
        s.MenuAtlas.preload { preloadGroup.leave() }
        
        preloadGroup.enter()
        s.GameAtlas.preload { preloadGroup.leave() }
        
        preloadGroup.enter()
        s.emitter.Particles.preload { preloadGroup.leave() }

        // Background & ground
        s.addChild(s.background)
        s.groundHitBox.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: s.groundHitBox.size.width, height: 1)
        )
        s.groundHitBox.position = CGPoint(x: s.size.width/2, y: 44)
        s.groundHitBox.physicsBody?.isDynamic = false
        s.groundHitBox.physicsBody?.affectedByGravity = false
        s.groundHitBox.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        s.groundHitBox.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        s.groundHitBox.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        s.groundHitBox.zPosition = 10
        s.addChild(s.groundHitBox)

        // Emitters
        s.addChild(s.emitter)
        s.emitter.addEmitterOnPlayer(
            fileName: "airParticles",
            position: CGPoint(x: s.size.width + 10, y: s.size.height / 2),
            deleteTime: -1
        )

        // Menu
        presentInitialMenu()

        // Player
        s.addChild(s.player)
        s.player.position = CGPoint(x: s.size.width/2, y: s.size.height/2)
        s.player.zPosition = 99
        s.player.updateCostume()

        // Landscapes
        s.landscapeBin.addChild(s.landscape1)
        s.landscape2.position.x += s.landscape2.size.width
        s.landscapeBin.addChild(s.landscape2)
        s.landscapeBin.name = "landscapeBin"
        s.landscapeBin.position = .zero
        s.addChild(s.landscapeBin)

        // Scrolling ground
        s.scrollingGroundBin.addChild(s.scrollingGround)
        s.scrollingGround1.position.x += s.scrollingGround1.size.width
        s.scrollingGroundBin.addChild(s.scrollingGround1)
        s.scrollingGroundBin.name = "scrollingGroundBin"
        s.scrollingGroundBin.position = .zero
        s.addChild(s.scrollingGroundBin)


        if s.const.highScore == 0 {
            s.const.setGameTut(value: true)
        }

        s.pauseButton.position = CGPoint(x: s.pauseButton.size.width, y: s.scrollingGround.size.height)
        s.pauseButton.zPosition = 101
        s.pauseButton.name = "pause"
    }

    /// Present initial menu at game startup
    func presentInitialMenu() {
        guard let s = scene else { return }
        // Texture already preloaded in setup()
        // Create and configure the main menu
        s.menu = Menu(size: s.size)
        s.menu.position = CGPoint(x: s.size.width/2, y: s.size.height/2)
        s.menu.zPosition = 100
        s.addChild(s.menu)
        s.menu.show()
    }

    /// Show the main menu
    func showMenu() {
        guard let s = scene else { return }
        let fade = SKAction.fadeOut(withDuration: 0.25)
        s.endScreen.run(fade) {
            s.endScreen.removeFromParent()
            s.addChild(s.menu)
            s.menu.playButton.removeAllActions()
            s.menu.show()
        }
    }

    /// Display crown overlay
    func showCrown() {
        guard let s = scene else { return }
        s.menu.hide()
        s.addChild(s.crown)
        s.crown.show()
    }

    /// Display settings overlay
    func showSettings() {
        guard let s = scene else { return }
        s.menu.hide()
        s.addChild(s.settings)
        s.settings.show()
    }

    /// Display shop overlay
    func showShop() {
        guard let s = scene else { return }
        s.menu.hide()
        s.addChild(s.shop)
        s.shop.show()
    }

    /// Start or restart gameplay
    func runGame() {
        guard let s = scene else { return }
        // Texture already preloaded in setup()

        s.const.gameOver = false
        s.player.removeHome()
        s.addChild(s.pauseButton)

        if s.const.gameTutorialOn {
            s.addChild(s.tut)
            s.tut.position = CGPoint(x: 0, y: -s.size.width/1.5)
            s.tut.show()
        }

        s.emitter.addEmitter(position: s.player.position)

        // HUD
        s.HUD = gameHUD(size: s.size, player: s.player)
        s.HUD.addLife(howMany: 3)
        s.HUD.position.x = -(s.size.width/2)
        s.addChild(s.HUD)

        // Remove menu
        s.menu.removeFromParent()

        // Spawn eggs via GameLogic
        let spawnAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.createEgg() },
                SKAction.wait(forDuration: createEggGameMode())
            ])
        )
        s.run(spawnAction, withKey: "createEgg")

        s.scrollingGroundBin.isPaused = false
        s.landscapeBin.isPaused = false
        s.randomMax = 26

        switch s.const.gameDifficulty {
        case 0: s.eagleSpeed = 0.0005
        case 1: s.eagleSpeed = 0.007
        default: s.eagleSpeed = 0.01
        }
    }

    /// Clean up and show end‐of‐game screen
    func endGame() {
        guard let s = scene else { return }
        s.const.gameOver = true
        s.player.addHome()
        s.gameSpeed = 7
        s.emitter.resetSpeed()

        s.pauseButton.removeFromParent()
        s.HUD.removeFromParent()
        s.HUD.scoreLabel.text = "0"
        s.HUD.labelShadow.text = "0"
        s.tut.delete()
        s.fox.stop()
        s.eagle.stop()
        s.removeAction(forKey: "createEgg")

        // Remove eggs
        s.children
         .filter { $0.name?.hasPrefix("egg") == true }
         .forEach { [weak self] node in
             self?.deleteEgg(egg: node)
         }

        // High score
        if s.scoreNum > s.const.highScore {
            s.const.highScore = s.scoreNum
        }
        if s.scoreNum >= 10 {
            s.const.setGameTut(value: false)
        }

        s.landscapeBin.isPaused = true
        s.scrollingGroundBin.isPaused = true
        s.landscapeBin.action(forKey: "landscapeBinMoveLeft")?.speed = 1
        s.scrollingGroundBin.action(forKey: "scrollingGroundBinMoveLeft")?.speed = 1

        // End screen
        s.endScreen = EndScreen(size: s.size, score: s.scoreNum)
        s.addChild(s.endScreen)
        s.scoreNum = 0
    }

    /// Pause / resume toggle
    func showPauseScreen() {
        guard let s = scene else { return }
        s.addChild(s.pauseScreen)
        guard let physicsBody = s.player.physicsBody else { return }
        if physicsBody.isDynamic {
            s.playerVelocity = physicsBody.velocity
            physicsBody.isDynamic = false
        } else {
            physicsBody.isDynamic = true
            physicsBody.velocity = s.playerVelocity
        }
        s.newPaused = true
    }

    /// Spawn a standard or golden egg
    func createEgg() {
        guard let s = scene, !s.const.gameOver else { return }
        
        let isGold = Int.random(in: 1...15) == 7
        let egg = getPooledEgg(isGold: isGold)
        
        if isGold {
            if let emitter = SKEmitterNode(fileNamed: "eggCoin") {
                emitter.targetNode = s
                egg.addChild(emitter)
            }
        }
        
        let maxY = s.size.height - egg.size.height * 3
        let minY = egg.size.height + 100
        let range = maxY - minY
        let y = maxY - CGFloat.random(in: 0...range)
        egg.position = CGPoint(x: s.size.width, y: y)

        s.addChild(egg)
        egg.run(
            .sequence([
                .moveBy(x: -s.size.width, y: 0, duration: s.gameSpeed),
                .run { [weak self] in
                    self?.returnEggToPool(egg)
                }
            ])
        )
    }

    /// Animate and remove a collected egg
    func deleteEgg(egg: SKNode) {
        guard let s = scene, let eggNode = egg as? Egg else { return }
        
        if egg.name == "GoldenEgg" {
            egg.removeAllActions()
            egg.physicsBody = nil
            s.HUD.goldenEggUpdate()
            let move = SKAction.move(
                to: CGPoint(x: egg.frame.width, y: s.HUD.goldenEgg.position.y),
                duration: 0.85
            )
            move.timingMode = .easeInEaseOut
            let returnToPool = SKAction.run { [weak self] in
                self?.returnEggToPool(eggNode)
            }
            egg.run(.sequence([move, .wait(forDuration: 1.0), returnToPool]))
        } else {
            s.emitter.addEmitter(position: egg.position)
            returnEggToPool(eggNode)
        }
    }

    /// Update score, difficulty scaling, and random enemy spawn
    func setScore(eggType: String) {
        guard let s = scene else { return }
        if s.gameSpeed > 2 {
            s.eggSpeed /= 0.99
            s.gameSpeed *= 0.989
            s.eagleSpeed /= 0.99
            s.landscapeBin.action(forKey: "landscapeBinMoveLeft")?.speed += 0.017
            s.scrollingGroundBin.action(forKey: "scrollingGroundBinMoveLeft")?.speed += 0.010
        }
        if s.scoreNum >= 2 {
            s.tut.delete()
        }
        if eggType == "GoldenEgg" {
            s.const.goldenEggs += 1
            UserDefaults.standard.set(s.const.goldenEggs, forKey: "goldenEggs")
        } else {
            s.scoreNum += 1
        }
        s.HUD.scoreLabel.text = "\(s.scoreNum)"
        s.HUD.labelShadow.text = "\(s.scoreNum)"
        if s.const.gameDifficulty != 0, s.scoreNum % 15 == 1, s.randomMax >= 7 {
            s.randomMax -= 1
            if Int.random(in: 1...s.randomMax) == 7 {
                randomEnemy()
            }
        }
    }

    /// Spawn a fox on the ground
    func spawnEnemy() {
        guard let s = scene else { return }
        s.HUD.enemyShadow.isHidden = false
        s.fox = getPooledFox()
        s.fox.onStopped = { [weak self] fox in
            self?.returnFoxToPool(fox)
        }
        s.fox.position = CGPoint(
            x: s.size.width,
            y: s.groundHitBox.position.y + s.fox.size.height
        )
        s.fox.zPosition = 100
        s.addChild(s.fox)
        s.fox.run(speed: s.gameSpeed, viewSize: s.size)
    }

    /// Randomly spawn fox or eagle
    func randomEnemy() {
        guard let s = scene, !s.const.gameOver else { return }
        if Int.random(in: 1...2) == 1, !s.eagle.isRunning() {
            s.eagle = getPooledEagle()
            s.eagle.onStopped = { [weak self] eagle in
                self?.returnEagleToPool(eagle)
            }
            s.eagle.position = CGPoint(x: s.size.width + s.eagle.size.width, y: s.size.height/2)
            s.addChild(s.eagle)
            s.eagle.run(speed: s.gameSpeed, viewSize: s.size)
        } else if !s.fox.isRunning() {
            spawnEnemy()
        }
    }

    /// Return egg-spawn interval based on difficulty
    func createEggGameMode() -> TimeInterval {
        guard let s = scene else { return 1.0 }
        switch s.const.gameDifficulty {
        case 0: return 0.8
        case 1: return 1.0
        default: return 0.5
        }
    }
    
    /// Per-frame game logic updates (called from GameScene.update)
    func update(currentTime: TimeInterval) {
        guard let s = scene else { return }
        
        // Cache velocity for reuse to avoid multiple property access
        guard let playerPhysicsBody = s.player.physicsBody else { return }
        let playerVelocity = playerPhysicsBody.velocity
        let isPlayerStationary = playerVelocity == CGVector(dx: 0, dy: 0)

        // Handle player flap animation
        if isPlayerStationary {
            s.player.removeAction(forKey: "flap")
            s.player.texture = s.player.playerImage
        } else if s.player.action(forKey: "flap") == nil {
            s.player.flap()
        }

        // Handle drag-based horizontal movement
        if s.touched {
            // Move player towards touch location
            var dx = s.location.x - s.player.position.x
            let speed: CGFloat = 0.08
            dx *= speed
            s.player.position.x += dx
            // Update player shadow on HUD
            s.HUD.playerShadow.position.x = s.player.position.x + s.size.width / 2
        }

        // Update HUD shadows for player
        s.HUD.updateShadow(userOfShadow: "player", currentPos: s.player.position.y)

        // Update HUD shadows for fox if active
        if s.fox.isRunning() {
            s.HUD.updateShadow(userOfShadow: "fox", currentPos: s.fox.position.y)
            s.HUD.enemyShadow.position.x = (s.fox.position.x + s.size.width / 2) - 5
        }

        // Spawn additional fox if conditions are met
        if isPlayerStationary
            && !s.const.gameOver
            && !s.fox.isRunning()
            && s.scoreNum > 0
            && s.const.gameDifficulty != 0 {
            spawnEnemy()
        }
    }
    
    // MARK: - Object Pool Management
    
    /// Get an egg from the pool or create a new one
    private func getPooledEgg(isGold: Bool = false) -> Egg {
        let pool = isGold ? goldEggPool : eggPool
        
        if let egg = pool.last {
            if isGold {
                goldEggPool.removeLast()
            } else {
                eggPool.removeLast()
            }
            // Reset egg properties
            egg.removeAllActions()
            egg.removeAllChildren()
            egg.physicsBody?.isDynamic = false
            egg.alpha = 1.0
            return egg
        } else {
            // Create new egg if pool is empty
            return Egg(isGold: isGold)
        }
    }
    
    /// Return an egg to the pool
    private func returnEggToPool(_ egg: Egg) {
        egg.removeFromParent()
        egg.removeAllActions()
        egg.removeAllChildren()
        
        let isGold = egg.name == "GoldenEgg"
        let pool = isGold ? goldEggPool : eggPool
        
        if pool.count < maxPoolSize {
            if isGold {
                goldEggPool.append(egg)
            } else {
                eggPool.append(egg)
            }
        }
        // If pool is full, let the egg be deallocated naturally
    }
    
    /// Get a fox from the pool or create a new one
    private func getPooledFox() -> Fox {
        if let fox = foxPool.last {
            foxPool.removeLast()
            fox.removeAllActions()
            fox.removeAllChildren()
            fox.running = false
            return fox
        } else {
            return Fox()
        }
    }
    
    /// Return a fox to the pool
    private func returnFoxToPool(_ fox: Fox) {
        fox.removeFromParent()
        fox.removeAllActions()
        fox.removeAllChildren()
        fox.running = false
        
        if foxPool.count < maxPoolSize {
            foxPool.append(fox)
        }
    }
    
    /// Get an eagle from the pool or create a new one
    private func getPooledEagle() -> Eagle {
        if let eagle = eaglePool.last {
            eaglePool.removeLast()
            eagle.removeAllActions()
            eagle.removeAllChildren()
            eagle.running = false
            return eagle
        } else {
            return Eagle()
        }
    }
    
    /// Return an eagle to the pool
    private func returnEagleToPool(_ eagle: Eagle) {
        eagle.removeFromParent()
        eagle.removeAllActions()
        eagle.removeAllChildren()
        eagle.running = false
        
        if eaglePool.count < maxPoolSize {
            eaglePool.append(eagle)
        }
    }
    
    /// Spawn eagle from roof collision (called by PhysicsContactHandler)
    func spawnEagleFromRoof() {
        guard let s = scene else { return }
        s.eagle = getPooledEagle()
        s.eagle.onStopped = { [weak self] eagle in
            self?.returnEagleToPool(eagle)
        }
        s.eagle.position = CGPoint(x: s.size.width + s.eagle.size.width,
                                   y: s.size.height / 2)
        s.addChild(s.eagle)
        s.eagle.run(speed: s.gameSpeed, viewSize: s.size)
    }
}
