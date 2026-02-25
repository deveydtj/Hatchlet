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
    private let extraEggGravity: CGFloat = -70
    private var lastUpdateTime: TimeInterval = 0
    private var eggSpawnAccumulator: TimeInterval = 0
    private var eggLaunchingEnabled: Bool = false
    private weak var introFoxNode: SKSpriteNode?

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

        // Warm enemy pools so first spawn never allocates/setup on-frame.
        prewarmEnemyPools()

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

    private func prewarmEnemyPools() {
        guard let s = scene else { return }

        if foxPool.isEmpty {
            s.fox.removeAllActions()
            s.fox.removeAllChildren()
            s.fox.removeFromParent()
            s.fox.running = false
            foxPool.append(s.fox)
        }

        if eaglePool.isEmpty {
            s.eagle.removeAllActions()
            s.eagle.removeAllChildren()
            s.eagle.removeFromParent()
            s.eagle.running = false
            eaglePool.append(s.eagle)
        }
    }

    /// Present initial menu at game startup
    func presentInitialMenu() {
        guard let s = scene else { return }
        s.landscapeBin.isPaused = true
        s.scrollingGroundBin.isPaused = true
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
        s.landscapeBin.isPaused = true
        s.scrollingGroundBin.isPaused = true
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
        s.newPaused = false
        s.pauseScreen.removeFromParent()
        s.eggSpeed = 50
        lastUpdateTime = 0
        eggSpawnAccumulator = 0
        eggLaunchingEnabled = false
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

        // Start with an intro fox pass, then begin normal egg launching.
        startIntroFoxSequence()

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
        eggLaunchingEnabled = false
        introFoxNode?.removeAllActions()
        introFoxNode?.removeFromParent()
        introFoxNode = nil
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
        eggSpawnAccumulator = 0

        // Remove eggs
        s.children
         .compactMap { $0 as? Egg }
         .forEach { [weak self] eggNode in
             self?.recycleEgg(egg: eggNode)
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
        guard let s = scene, !s.const.gameOver, eggLaunchingEnabled else { return }

        let isGold = Int.random(in: 1...15) == 7
        let egg = getPooledEgg(isGold: isGold)

        if isGold {
            if let emitter = s.emitter.makeEmitter(fileName: "eggCoin") {
                emitter.targetNode = s
                egg.addChild(emitter)
            }
        }

        launchEgg(egg)
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

    /// Remove egg without score/effects (missed egg cleanup)
    func recycleEgg(egg: SKNode) {
        guard let eggNode = egg as? Egg else { return }
        returnEggToPool(eggNode)
    }

    /// Update score, difficulty scaling, and random enemy spawn
    func setScore(eggType: String) {
        guard let s = scene else { return }
        if s.gameSpeed > 2 {
            s.eggSpeed /= 0.995
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

    private func startIntroFoxSequence() {
        guard let s = scene, !s.const.gameOver else { return }

        introFoxNode?.removeAllActions()
        introFoxNode?.removeFromParent()

        let introFox = SKSpriteNode(
            texture: s.GameAtlas.textureNamed("fox"),
            color: .clear,
            size: s.fox.size
        )
        introFox.name = "introFox"
        introFox.zPosition = 100

        let carriedEgg = SKSpriteNode(
            texture: s.GameAtlas.textureNamed("egg"),
            color: .clear,
            size: CGSize(width: 24, height: 28)
        )
        carriedEgg.name = "introCarriedEgg"
        carriedEgg.position = CGPoint(
            x: -(introFox.size.width * 0.5) + (carriedEgg.size.width * 0.55),
            y: introFox.size.height * 0.02
        )
        carriedEgg.zPosition = 1
        introFox.addChild(carriedEgg)

        let groundY = s.groundHitBox.position.y + introFox.size.height * 0.52
        introFox.position = CGPoint(
            x: s.frame.maxX - introFox.size.width * 0.72,
            y: groundY
        )
        s.addChild(introFox)
        introFoxNode = introFox

        let shakeLeft = SKAction.rotate(toAngle: 0.28, duration: 0.06, shortestUnitArc: true)
        let shakeRight = SKAction.rotate(toAngle: -0.28, duration: 0.06, shortestUnitArc: true)
        let settleShake = SKAction.rotate(toAngle: 0, duration: 0.10, shortestUnitArc: true)
        let shakeEgg = SKAction.sequence([shakeLeft, shakeRight, shakeLeft, shakeRight, shakeLeft, shakeRight, settleShake])
        carriedEgg.run(.repeat(shakeEgg, count: 3))

        let pauseBeforeRun = SKAction.wait(forDuration: 1.25)
        let moveOffscreenRight = SKAction.moveTo(
            x: s.frame.maxX + introFox.size.width * 1.6,
            duration: 1.55
        )
        moveOffscreenRight.timingMode = .easeInEaseOut
        let finishIntro = SKAction.run { [weak self] in
            guard let self else { return }
            self.introFoxNode?.removeFromParent()
            self.introFoxNode = nil
            self.beginEggLaunching()
        }
        introFox.run(.sequence([pauseBeforeRun, moveOffscreenRight, finishIntro]))
    }

    private func beginEggLaunching() {
        guard let s = scene, !s.const.gameOver else { return }
        eggLaunchingEnabled = true
        eggSpawnAccumulator = 0
        createEgg()
        s.HUD.enemyShadow.isHidden = true
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
        case 0: return 1.5
        case 1: return 1.25
        default: return 0.95
        }
    }
    
    /// Per-frame game logic updates (called from GameScene.update)
    func update(currentTime: TimeInterval) {
        guard let s = scene else { return }

        let deltaTime: CGFloat
        if lastUpdateTime == 0 {
            deltaTime = 1.0 / 60.0
        } else {
            deltaTime = CGFloat(min(currentTime - lastUpdateTime, 0.05))
        }
        lastUpdateTime = currentTime

        if !s.const.gameOver && !s.newPaused && s.menu.parent == nil && eggLaunchingEnabled {
            eggSpawnAccumulator += TimeInterval(deltaTime)
            let spawnInterval = createEggGameMode()
            while eggSpawnAccumulator >= spawnInterval {
                createEgg()
                eggSpawnAccumulator -= spawnInterval
            }
        }

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

        // Boost gravity for eggs so trajectories form readable arcs.
        let gameplayActive = !s.const.gameOver && !s.newPaused && s.menu.parent == nil
        let visibleFrame = s.frame
        for egg in s.children.compactMap({ $0 as? Egg }) {
            guard let eggBody = egg.physicsBody, eggBody.isDynamic else { continue }

            if gameplayActive {
                var velocity = eggBody.velocity
                velocity.dy += extraEggGravity * deltaTime
                eggBody.velocity = velocity
            }

            let outOfBoundsLeft = egg.position.x < visibleFrame.minX - egg.size.width * 6
            let outOfBoundsRight = egg.position.x > visibleFrame.maxX + egg.size.width * 6
            let outOfBoundsBottom = egg.position.y < visibleFrame.minY - egg.size.height * 6
            let outOfBoundsTop = egg.position.y > visibleFrame.maxY + egg.size.height * 6

            if outOfBoundsLeft || outOfBoundsRight || outOfBoundsBottom || outOfBoundsTop {
                returnEggToPool(egg)
            }
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
            egg.configurePhysicsForFlight()
            egg.physicsBody?.velocity = .zero
            egg.physicsBody?.angularVelocity = 0
            egg.physicsBody?.isDynamic = false
            egg.alpha = 1.0
            egg.zRotation = 0

            // Ensure egg properties match the requested type
            egg.isGoldenEgg = isGold
            if isGold {
                egg.texture = egg.goldenEggTexture
                egg.name = "GoldenEgg"
            } else {
                egg.texture = egg.eggTexture
                egg.name = "egg"
            }
            
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
        egg.physicsBody?.velocity = .zero
        egg.physicsBody?.angularVelocity = 0
        egg.physicsBody?.isDynamic = false
        egg.zRotation = 0

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

    private func launchEgg(_ egg: Egg) {
        guard let s = scene else { return }

        egg.configurePhysicsForFlight()
        let visibleFrame = s.frame
        let spawnX = visibleFrame.maxX + egg.size.width + CGFloat.random(in: 20...70)
        let spawnY = visibleFrame.minY - egg.size.height * 0.15 + CGFloat.random(in: -6...14)
        egg.position = CGPoint(x: spawnX, y: spawnY)

        let speedMultiplier = CGFloat(max(0.88, min(1.28, s.eggSpeed / 50.0)))
        let horizontalMultiplier = 0.88 + ((speedMultiplier - 0.88) * 0.24)
        let verticalMultiplier = 0.98 + ((speedMultiplier - 0.88) * 0.20)
        let launchVelocityX = -CGFloat.random(in: 170...255) * horizontalMultiplier
        let launchVelocityY = CGFloat.random(in: 880...1120) * verticalMultiplier

        if egg.parent == nil {
            s.addChild(egg)
        }
        egg.physicsBody?.isDynamic = true
        egg.physicsBody?.velocity = CGVector(dx: launchVelocityX, dy: launchVelocityY)
        egg.physicsBody?.angularVelocity = CGFloat.random(in: -4.5...4.5)
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
