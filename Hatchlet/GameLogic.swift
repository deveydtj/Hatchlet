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
    private struct EggLaunchProfile {
        var spawnXOffsetProgress: CGFloat
        var spawnYOffsetProgress: CGFloat
        var horizontalVelocityProgress: CGFloat
        var apexXProgress: CGFloat
        var verticalVelocityScaleProgress: CGFloat
    }

    private weak var scene: GameScene?
    
    // Object pools for performance optimization
    private var eggPool: [Egg] = []
    private var goldEggPool: [Egg] = []
    private var foxPool: [Fox] = []
    private var eaglePool: [Eagle] = []
    private let maxPoolSize = 10
    private let eggBurstSpacing: TimeInterval = 0.08
    private let extraEggGravity: CGFloat = -70
    private let groundTrailSpawnDistance: CGFloat = 18
    private let groundedVerticalSpeedThreshold: CGFloat = 25
    private let groundedHeightTolerance: CGFloat = 12
    private var lastUpdateTime: TimeInterval = 0
    private var eggSpawnAccumulator: TimeInterval = 0
    private var groundTrailDistanceAccumulator: CGFloat = 0
    private var previousPlayerX: CGFloat?
    private var eggLaunchingEnabled: Bool = false
    // Tracks golden egg HUD travel animations that have been triggered but not yet
    // applied to the displayed HUD count (which updates only after travel completes).
    private var pendingGoldenEggCountIncrements: Int = 0
    private weak var introFoxNode: SKSpriteNode?
    private var previousEggLaunchProfile: EggLaunchProfile?
    private var eggCatchStreak: Int = 0
    private var bestEggCatchStreak: Int = 0

    init(scene: GameScene) {
        self.scene = scene
    }

    /// Initial scene setup (moved from GameScene.setup())
    func setup() {
        guard let s = scene else { return }
        s.physicsWorld.contactDelegate = s
        s.isUserInteractionEnabled = false
        
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

        // Static roof collider (single segment) so head collisions are consistent.
        s.roofHitBox.physicsBody = SKPhysicsBody(rectangleOf: s.roofHitBox.size)
        s.roofHitBox.position = CGPoint(x: s.size.width / 2, y: s.size.height + s.roofHitBox.size.height)
        s.roofHitBox.physicsBody?.isDynamic = false
        s.roofHitBox.physicsBody?.affectedByGravity = false
        s.roofHitBox.physicsBody?.categoryBitMask = PhysicsCategory.Roof
        s.roofHitBox.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        s.roofHitBox.physicsBody?.contactTestBitMask = PhysicsCategory.None
        s.roofHitBox.zPosition = 10
        s.addChild(s.roofHitBox)

        // Emitters
        s.addChild(s.emitter)
        s.emitter.addEmitterOnPlayer(
            fileName: "airParticles",
            position: CGPoint(x: s.size.width + 10, y: s.size.height / 2),
            deleteTime: -1
        )
        s.emitter.setAirParticlesActive(false)

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
        
        preloadGroup.enter()
        SKTexture.preload(initialUITextures(in: s)) {
            preloadGroup.leave()
        }
        
        preloadGroup.notify(queue: .main) { [weak s] in
            s?.isUserInteractionEnabled = true
        }
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
    
    private func initialUITextures(in scene: GameScene) -> [SKTexture] {
        let menuTextures = [
            scene.menu.playButton.texture,
            scene.menu.shopButton.texture,
            scene.menu.settingsButton.texture,
            scene.menu.crownButton.texture
        ].compactMap { $0 } + scene.menu.playArray
        
        let settingsTextures = [
            scene.settings.backButton.texture,
            scene.settings.eggSwitch.texture,
            scene.settings.gameDiff.texture
        ].compactMap { $0 } + scene.settings.eggSwitchArray
        
        let tutorialTextures = [
            scene.tut.tut.texture
        ].compactMap { $0 } + scene.tut.tutArray
        
        let overlayTextures = [
            scene.pauseButton.texture,
            scene.shop.backButton.texture,
            scene.shop.goldenEgg.texture,
            scene.crown.backButton.texture,
            scene.player.texture,
            scene.player.playerImage,
            scene.player.playerBlink,
            scene.player.playerFlap,
            scene.player.playerOuch
        ].compactMap { $0 }
        
        let itemTextures = scene.shop.availableItems.map(\.texture)
        
        return menuTextures + settingsTextures + tutorialTextures + overlayTextures + itemTextures
    }

    /// Present initial menu at game startup
    func presentInitialMenu() {
        guard let s = scene else { return }
        setScrollingEnabled(false)
        // Texture already preloaded in setup()
        // Create and configure the main menu
        s.menu = Menu(size: s.size)
        s.menu.position = CGPoint(x: s.size.width/2, y: s.size.height/2)
        s.menu.zPosition = 100
        s.addChild(s.menu)
        s.menu.show()
        setIdlePresentationState(isIdle: true)
    }

    /// Show the main menu
    func showMenu() {
        guard let s = scene else { return }
        setScrollingEnabled(false)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        s.endScreen.run(fade) {
            s.endScreen.removeFromParent()
            s.addChild(s.menu)
            s.menu.playButton.removeAllActions()
            s.menu.show()
            self.setIdlePresentationState(isIdle: true)
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
        setIdlePresentationState(isIdle: false)
        s.newPaused = false
        s.pauseScreen.removeFromParent()
        s.eggSpeed = 50
        lastUpdateTime = 0
        eggSpawnAccumulator = 0
        groundTrailDistanceAccumulator = 0
        previousPlayerX = nil
        s.playerGroundContactCount = 0
        eggLaunchingEnabled = false
        pendingGoldenEggCountIncrements = 0
        previousEggLaunchProfile = nil
        eggCatchStreak = 0
        bestEggCatchStreak = 0
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
        s.HUD.setGoldenEggCount(s.const.goldenEggs)
        s.HUD.resetEggStreak()

        // Remove menu
        s.menu.removeFromParent()

        // Start with an intro fox pass, then begin normal egg launching.
        startIntroFoxSequence()

        setScrollingEnabled(true)
        s.randomMax = 26

        s.eagleSpeed = s.eagleTuning.baseSpeed(for: s.const.gameDifficulty)
    }

    /// Clean up and show end‐of‐game screen
    func endGame() {
        guard let s = scene else { return }
        let bestStreakForRun = bestEggCatchStreak
        s.const.gameOver = true
        s.emitter.setAirParticlesActive(false)
        eggLaunchingEnabled = false
        pendingGoldenEggCountIncrements = 0
        previousEggLaunchProfile = nil
        eggCatchStreak = 0
        bestEggCatchStreak = 0
        introFoxNode?.removeAllActions()
        introFoxNode?.removeFromParent()
        introFoxNode = nil
        s.player.addHome()
        s.gameSpeed = 7
        s.emitter.resetSpeed()

        s.pauseButton.removeFromParent()
        s.HUD.removeFromParent()
        s.HUD.scoreLabel.text = "0"
        s.tut.delete()
        s.fox.stop()
        s.eagle.stop()
        s.removeAction(forKey: "createEgg")
        eggSpawnAccumulator = 0
        groundTrailDistanceAccumulator = 0
        previousPlayerX = nil
        s.playerGroundContactCount = 0

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

        setScrollingEnabled(false)

        // End screen
        s.endScreen = EndScreen(size: s.size, score: s.scoreNum, bestStreak: bestStreakForRun)
        s.addChild(s.endScreen)
        setIdlePresentationState(isIdle: true)
        s.scoreNum = 0
    }

    /// Pause / resume toggle
    func showPauseScreen() {
        guard let s = scene else { return }
        s.addChild(s.pauseScreen)
        s.emitter.setAirParticlesActive(false)
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

    /// Spawn one or more eggs with a weighted random burst size.
    /// Extra eggs in a burst are fired in quick succession.
    func createEgg() {
        guard let s = scene, !s.const.gameOver, eggLaunchingEnabled else { return }

        let launchCount = randomEggLaunchCount()
        launchSingleEggIfAllowed()

        guard launchCount > 1 else { return }
        for burstIndex in 1..<launchCount {
            let wait = SKAction.wait(forDuration: eggBurstSpacing * Double(burstIndex))
            let launch = SKAction.run { [weak self] in
                self?.launchSingleEggIfAllowed()
            }
            s.run(.sequence([wait, launch]))
        }
    }

    /// Animate and remove a collected egg
    func deleteEgg(egg: SKNode) {
        guard let s = scene, let eggNode = egg as? Egg else { return }
        
        if egg.name == "GoldenEgg" {
            egg.removeAllActions()
            egg.physicsBody = nil

            // 1) Update authoritative currency immediately.
            let committedCount = s.const.goldenEggs + 1
            s.const.setGoldenEggs(value: committedCount)

            // 2) Trigger HUD icon feedback immediately, but delay the displayed
            //    number update until the traveling egg animation completes.
            pendingGoldenEggCountIncrements += 1
            s.HUD.goldenEggUpdate()

            let hudGoldenEggTarget = s.HUD.convert(s.HUD.goldenEgg.position, to: s)

            // Distance-aware duration (subtle) so eggs already near the HUD don't
            // feel laggy, but also never look unnaturally fast.
            let dx = hudGoldenEggTarget.x - egg.position.x
            let dy = hudGoldenEggTarget.y - egg.position.y
            let distance = sqrt((dx * dx) + (dy * dy))
            let moveDuration: TimeInterval
            if distance < 160 {
                moveDuration = 0.60
            } else if distance < 320 {
                moveDuration = 0.72
            } else {
                moveDuration = 0.85
            }

            let move = SKAction.move(
                to: hudGoldenEggTarget,
                duration: moveDuration
            )
            move.timingMode = .easeInEaseOut
            let alignRotation = SKAction.rotate(
                toAngle: s.HUD.goldenEgg.zRotation,
                duration: moveDuration,
                shortestUnitArc: true
            )
            let moveAndAlign = SKAction.group([move, alignRotation])
            let updateGoldenEggCount = SKAction.run { [weak self, weak s] in
                guard let self, let s else { return }
                self.pendingGoldenEggCountIncrements = max(0, self.pendingGoldenEggCountIncrements - 1)
                let displayCount = s.const.goldenEggs - self.pendingGoldenEggCountIncrements
                s.HUD.setGoldenEggCount(displayCount, animated: true)
                s.HUD.goldenEggCounterShow(travelDuration: moveDuration)
            }
            let returnToPool = SKAction.run { [weak self] in
                self?.returnEggToPool(eggNode)
            }
            egg.run(.sequence([moveAndAlign, updateGoldenEggCount, .wait(forDuration: 1.0), returnToPool]))
        } else {
            s.emitter.addEmitter(position: egg.position)
            returnEggToPool(eggNode)
        }
    }

    /// Remove egg without score/effects (missed egg cleanup)
    func recycleEgg(egg: SKNode) {
        guard let eggNode = egg as? Egg else { return }
        if shouldBreakEggStreakOnRecycle() {
            breakEggStreak(showFeedback: true)
        }
        returnEggToPool(eggNode)
    }

    /// Update score, difficulty scaling, and random enemy spawn
    func setScore(eggType: String, catchPosition: CGPoint) {
        guard let s = scene else { return }
        registerEggCatch(catchPosition: catchPosition)
        if s.gameSpeed > 2 {
            s.eggSpeed /= 0.995
            s.gameSpeed *= 0.989
            let rampedEagleSpeed = s.eagleSpeed / s.eagleTuning.speedRampDivisor
            s.eagleSpeed = min(rampedEagleSpeed, s.eagleTuning.maxSpeed(for: s.const.gameDifficulty))
            s.landscapeBin.action(forKey: "landscapeBinMoveLeft")?.speed += 0.017
            s.scrollingGroundBin.action(forKey: "scrollingGroundBinMoveLeft")?.speed += 0.010
        }
        if s.scoreNum >= 2 {
            s.tut.delete()
        }
        if eggType != "GoldenEgg" {
            s.scoreNum += 1
        }
        s.HUD.scoreLabel.text = "\(s.scoreNum)"
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
            s.eagle.run(
                speed: s.gameSpeed,
                viewSize: s.size,
                passDurationMultiplier: s.eagleTuning.passDurationMultiplier
            )
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

    private func randomEggLaunchCount() -> Int {
        guard let s = scene else { return 1 }
        let roll = Int.random(in: 1...100)

        switch s.const.gameDifficulty {
        case 0:
            if roll <= 72 { return 1 }
            if roll <= 95 { return 2 }
            return 3
        case 1:
            if roll <= 56 { return 1 }
            if roll <= 84 { return 2 }
            if roll <= 97 { return 3 }
            return 4
        default:
            if roll <= 42 { return 1 }
            if roll <= 74 { return 2 }
            if roll <= 93 { return 3 }
            return 4
        }
    }

    private func launchSingleEggIfAllowed() {
        guard let s = scene, !s.const.gameOver, eggLaunchingEnabled, !s.newPaused else { return }
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

        let gameplayActive = !s.const.gameOver && !s.newPaused && s.menu.parent == nil
        let idleInteractiveActive = s.const.gameOver && (s.menu.parent != nil || s.endScreen.parent != nil)
        let playerInteractiveActive = gameplayActive || idleInteractiveActive

        if gameplayActive && eggLaunchingEnabled {
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

        if !playerInteractiveActive {
            if s.player.action(forKey: "flap") != nil {
                s.player.removeAction(forKey: "flap")
                s.player.showDefaultTexture()
            }
            return
        }

        // Handle player flap animation
        if isPlayerStationary {
            if s.player.action(forKey: "flap") != nil {
                s.player.removeAction(forKey: "flap")
                s.player.showDefaultTexture()
            }
        } else if s.player.action(forKey: "flap") == nil {
            s.player.maybeQuickBlinkOnFlap()
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

        if previousPlayerX == nil {
            previousPlayerX = s.player.position.x
        }
        let deltaX = abs(s.player.position.x - (previousPlayerX ?? s.player.position.x))
        previousPlayerX = s.player.position.x

        let playerBottomY = s.player.position.y - (s.player.size.height * 0.5)
        let groundTopY = s.groundHitBox.position.y + (s.groundHitBox.size.height * 0.5)
        let verticalGroundGap = playerBottomY - groundTopY
        let isNearGroundSurface = verticalGroundGap <= groundedHeightTolerance

        // Guard against stale contact counters leaving the player "grounded" in mid-air.
        if s.isPlayerGrounded && !isNearGroundSurface {
            s.playerGroundContactCount = 0
        }
        let effectivelyGrounded = s.isPlayerGrounded && isNearGroundSurface

        let shouldSpawnGroundTrail =
            playerInteractiveActive
            && effectivelyGrounded
            && abs(playerVelocity.dy) < groundedVerticalSpeedThreshold
            && deltaX > 0.2

        if shouldSpawnGroundTrail {
            groundTrailDistanceAccumulator += deltaX
            while groundTrailDistanceAccumulator >= groundTrailSpawnDistance {
                s.emitter.addEmitterOnPlayer(fileName: "grass",
                                             position: s.player.position,
                                             deleteTime: 0.22)
                groundTrailDistanceAccumulator -= groundTrailSpawnDistance
            }
        } else if !effectivelyGrounded {
            groundTrailDistanceAccumulator = 0
        }

        // Boost gravity for eggs so trajectories form readable arcs.
        if gameplayActive {
            let visibleFrame = s.frame
            for egg in s.children.compactMap({ $0 as? Egg }) {
                guard let eggBody = egg.physicsBody, eggBody.isDynamic else { continue }

                var velocity = eggBody.velocity
                velocity.dy += extraEggGravity * deltaTime
                eggBody.velocity = velocity

                let outOfBoundsLeft = egg.position.x < visibleFrame.minX - egg.size.width * 6
                let outOfBoundsRight = egg.position.x > visibleFrame.maxX + egg.size.width * 6
                let outOfBoundsBottom = egg.position.y < visibleFrame.minY - egg.size.height * 6
                let outOfBoundsTop = egg.position.y > visibleFrame.maxY + egg.size.height * 6

                if outOfBoundsLeft || outOfBoundsRight || outOfBoundsBottom || outOfBoundsTop {
                    recycleEgg(egg: egg)
                }
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

    private func setIdlePresentationState(isIdle: Bool) {
        guard let s = scene else { return }
        s.emitter.setAirParticlesActive(!isIdle)
        guard let physicsBody = s.player.physicsBody else { return }
        physicsBody.velocity = .zero
        physicsBody.angularVelocity = 0
        let shouldKeepIdlePhysics = isIdle && (s.menu.parent != nil || s.endScreen.parent != nil)
        physicsBody.isDynamic = shouldKeepIdlePhysics || !isIdle
        if isIdle && !shouldKeepIdlePhysics {
            s.player.removeAction(forKey: "flap")
            s.player.showDefaultTexture()
        }
    }

    private func setScrollingEnabled(_ isEnabled: Bool) {
        guard let s = scene else { return }

        let scrollingNodes = [s.landscapeBin, s.scrollingGroundBin]
        let actionKeys = ["landscapeBinMoveLeft", "scrollingGroundBinMoveLeft"]

        if isEnabled {
            for node in scrollingNodes {
                node.isPaused = false
            }
            return
        }

        for (node, actionKey) in zip(scrollingNodes, actionKeys) {
            node.isPaused = true
            node.removeAction(forKey: actionKey)
            node.position = .zero
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

    private func nextEggLaunchProgress(previous: CGFloat?, maxStep: ClosedRange<CGFloat>) -> CGFloat {
        guard let previous else {
            return CGFloat.random(in: 0...1)
        }

        let step = CGFloat.random(in: maxStep)
        let direction: CGFloat = Bool.random() ? 1 : -1
        return min(max(previous + (direction * step), 0), 1)
    }

    private func registerEggCatch(catchPosition: CGPoint) {
        guard let s = scene else { return }
        eggCatchStreak += 1
        bestEggCatchStreak = max(bestEggCatchStreak, eggCatchStreak)
        s.HUD.celebrateEggStreak(eggCatchStreak, at: catchPosition)
    }

    private func breakEggStreak(showFeedback: Bool) {
        guard let s = scene else { return }
        let previousStreak = eggCatchStreak
        eggCatchStreak = 0

        guard showFeedback else {
            s.HUD.resetEggStreak()
            return
        }

        if previousStreak > 1 {
            s.HUD.breakEggStreak(previousStreak: previousStreak)
        } else {
            s.HUD.resetEggStreak()
        }
    }

    private func shouldBreakEggStreakOnRecycle() -> Bool {
        guard let s = scene else { return false }
        return eggCatchStreak > 0 && !s.const.gameOver && eggLaunchingEnabled
    }
    
    private func launchEgg(_ egg: Egg) {
        guard let s = scene else { return }

        egg.configurePhysicsForFlight()
        let visibleFrame = s.frame
        let launchProfile = EggLaunchProfile(
            spawnXOffsetProgress: nextEggLaunchProgress(
                previous: previousEggLaunchProfile?.spawnXOffsetProgress,
                maxStep: 0.05...0.18
            ),
            spawnYOffsetProgress: nextEggLaunchProgress(
                previous: previousEggLaunchProfile?.spawnYOffsetProgress,
                maxStep: 0.04...0.16
            ),
            horizontalVelocityProgress: nextEggLaunchProgress(
                previous: previousEggLaunchProfile?.horizontalVelocityProgress,
                maxStep: 0.05...0.17
            ),
            apexXProgress: nextEggLaunchProgress(
                previous: previousEggLaunchProfile?.apexXProgress,
                maxStep: 0.04...0.15
            ),
            verticalVelocityScaleProgress: nextEggLaunchProgress(
                previous: previousEggLaunchProfile?.verticalVelocityScaleProgress,
                maxStep: 0.05...0.18
            )
        )
        previousEggLaunchProfile = launchProfile

        let spawnXOffset = 20 + (50 * launchProfile.spawnXOffsetProgress)
        let spawnX = visibleFrame.maxX + egg.size.width + spawnXOffset
        let spawnBaselineY = max(
            s.groundHitBox.position.y + egg.size.height * 1.2,
            visibleFrame.minY + visibleFrame.height * 0.12
        )
        let spawnY = spawnBaselineY + (-10 + (28 * launchProfile.spawnYOffsetProgress))
        egg.position = CGPoint(x: spawnX, y: spawnY)

        let speedMultiplier = CGFloat(max(0.88, min(1.28, s.eggSpeed / 50.0)))
        let horizontalMultiplier = 0.88 + ((speedMultiplier - 0.88) * 0.24)
        let horizontalVelocity = 200 + (90 * launchProfile.horizontalVelocityProgress)
        var launchVelocityX = -horizontalVelocity * horizontalMultiplier

        // Aim the apex near the top while the egg is still moving through the visible play area.
        let gravityMagnitude = abs(s.physicsWorld.gravity.dy) + abs(extraEggGravity)
        let desiredApexY = visibleFrame.maxY + egg.size.height * 0.35
        let deltaYToApex = max(visibleFrame.height * 1.05, desiredApexY - spawnY)
        let apexXRatio = 0.28 + (0.10 * launchProfile.apexXProgress)
        let apexX = visibleFrame.maxX - visibleFrame.width * apexXRatio
        let horizontalDistanceToApex = max(visibleFrame.width * 0.34, spawnX - apexX)
        let timeToApex = max(0.66, horizontalDistanceToApex / abs(launchVelocityX))
        var launchVelocityY = (deltaYToApex + 0.5 * gravityMagnitude * timeToApex * timeToApex) / timeToApex
        let verticalVelocityScale = 1.00 + (0.14 * launchProfile.verticalVelocityScaleProgress)
        launchVelocityY *= verticalVelocityScale

        // Pre-check steep throws that would peak too low and leave the screen too quickly.
        func predictedHeight(at targetX: CGFloat, velocityY: CGFloat) -> CGFloat {
            let travelTime = max(0, (spawnX - targetX) / abs(launchVelocityX))
            return spawnY + velocityY * travelTime - 0.5 * gravityMagnitude * travelTime * travelTime
        }

        func minimumLaunchVelocity(targetX: CGFloat,
                                   targetHeightRatio: CGFloat,
                                   minimumTime: CGFloat) -> CGFloat {
            let travelTime = max(minimumTime, (spawnX - targetX) / abs(launchVelocityX))
            let targetHeight = visibleFrame.minY + visibleFrame.height * targetHeightRatio
            let requiredRise = max(0, targetHeight - spawnY)
            return (requiredRise + 0.5 * gravityMagnitude * travelTime * travelTime) / travelTime
        }

        let baseLaunchVelocityY = launchVelocityY
        let baseLaunchAngle = atan2(baseLaunchVelocityY, abs(launchVelocityX))
        let steepAngleThreshold: CGFloat = 1.12 // ~64 degrees
        let isSteepThrow = baseLaunchAngle > steepAngleThreshold
        var correctionReasons: [String] = []

        if isSteepThrow {
            let minimumSteepApexHeight = visibleFrame.minY + visibleFrame.height * 0.78
            let predictedApexHeight = spawnY + (baseLaunchVelocityY * baseLaunchVelocityY) / (2 * gravityMagnitude)
            let predictedTimeToApex = baseLaunchVelocityY / gravityMagnitude
            let minimumApexTravel = visibleFrame.width * 0.22
            let predictedApexTravel = abs(launchVelocityX) * predictedTimeToApex
            let minimumSteepVerticalSpeed = CGFloat(820) * speedMultiplier
            let minimumSteepHorizontalSpeed = CGFloat(225) * horizontalMultiplier
            let rightSideTargetX = visibleFrame.maxX - visibleFrame.width * 0.18
            let rightSideTargetHeight = visibleFrame.minY + visibleFrame.height * 0.50
            let isApexTooLow = predictedApexHeight < minimumSteepApexHeight
            let isApexTooCloseToRight = predictedApexTravel < minimumApexTravel
            let isSteepVerticalSpeedTooLow = baseLaunchVelocityY < minimumSteepVerticalSpeed
            let isSteepHorizontalSpeedTooLow = abs(launchVelocityX) < minimumSteepHorizontalSpeed
            let isRightSideTooLow =
                predictedHeight(at: rightSideTargetX, velocityY: baseLaunchVelocityY) < rightSideTargetHeight

            if isApexTooLow
                || isApexTooCloseToRight
                || isRightSideTooLow
                || isSteepVerticalSpeedTooLow
                || isSteepHorizontalSpeedTooLow {
                if isApexTooLow {
                    correctionReasons.append("low-apex")
                }
                if isApexTooCloseToRight {
                    correctionReasons.append("short-travel")
                }
                if isRightSideTooLow {
                    correctionReasons.append("low-right")
                }
                if isSteepVerticalSpeedTooLow {
                    correctionReasons.append("steep-low-v")
                }
                if isSteepHorizontalSpeedTooLow {
                    correctionReasons.append("steep-slow-x")
                }
                let apexRise = max(0, minimumSteepApexHeight - spawnY)
                let minimumApexLaunchVelocityY = sqrt(2 * gravityMagnitude * apexRise)
                let rightSideMinimumLaunchVelocityY = minimumLaunchVelocity(
                    targetX: rightSideTargetX,
                    targetHeightRatio: 0.46,
                    minimumTime: 0.46
                )
                let correctedVelocityY = max(
                    minimumApexLaunchVelocityY,
                    max(rightSideMinimumLaunchVelocityY, minimumSteepVerticalSpeed)
                )
                launchVelocityY = min(max(baseLaunchVelocityY, correctedVelocityY), baseLaunchVelocityY + 130)

                let correctedTimeToApex = launchVelocityY / gravityMagnitude
                let minimumHorizontalSpeed = minimumApexTravel / correctedTimeToApex
                launchVelocityX = -max(abs(launchVelocityX), max(minimumHorizontalSpeed, minimumSteepHorizontalSpeed))
            }
        }

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
        s.eagle.run(
            speed: s.gameSpeed,
            viewSize: s.size,
            passDurationMultiplier: s.eagleTuning.passDurationMultiplier
        )
    }
}
