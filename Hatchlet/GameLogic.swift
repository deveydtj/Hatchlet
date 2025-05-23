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

    init(scene: GameScene) {
        self.scene = scene
    }

    /// Initial scene setup (moved from GameScene.setup())
    func setup() {
        guard let s = scene else { return }
        s.physicsWorld.contactDelegate = s
        Constant.preload { }

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


        if UserDefaults.standard.integer(forKey: "highScore") == 0 {
            s.const.setGameTut(value: true)
        }

        s.pauseButton.position = CGPoint(x: s.pauseButton.size.width, y: s.scrollingGround.size.height)
        s.pauseButton.zPosition = 101
        s.pauseButton.name = "pause"
    }

    /// Present initial menu at game startup
    func presentInitialMenu() {
        guard let s = scene else { return }
        s.MenuAtlas.preload { }
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
        s.GameAtlas.preload { }

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
        if s.scoreNum > UserDefaults.standard.integer(forKey: "highScore") {
            UserDefaults.standard.set(s.scoreNum, forKey: "highScore")
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
        if s.player.physicsBody!.isDynamic {
            s.playerVelocity = s.player.physicsBody!.velocity
            s.player.physicsBody!.isDynamic = false
        } else {
            s.player.physicsBody!.isDynamic = true
            s.player.physicsBody!.velocity = s.playerVelocity
        }
        s.newPaused = true
    }

    /// Spawn a standard or golden egg
    func createEgg() {
        guard let s = scene, !s.const.gameOver else { return }
        let egg: Egg
        if Int.random(in: 1...15) == 7 {
            egg = Egg(isGold: true)
            if let emitter = SKEmitterNode(fileNamed: "eggCoin") {
                emitter.targetNode = s
                egg.addChild(emitter)
            }
        } else {
            egg = Egg()
        }
        let maxY = s.size.height - egg.size.height * 3
        let minY = egg.size.height + 100
        let range = maxY - minY
        let y = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        egg.position = CGPoint(x: s.size.width, y: y)

        s.addChild(egg)
        egg.run(
            .sequence([
                .moveBy(x: -s.size.width, y: 0, duration: s.gameSpeed),
                .removeFromParent()
            ])
        )
    }

    /// Animate and remove a collected egg
    func deleteEgg(egg: SKNode) {
        guard let s = scene else { return }
        if egg.name == "GoldenEgg" {
            egg.removeAllActions()
            egg.physicsBody = nil
            s.HUD.goldenEggUpdate()
            let move = SKAction.move(
                to: CGPoint(x: egg.frame.width, y: s.HUD.goldenEgg.position.y),
                duration: 0.85
            )
            move.timingMode = .easeInEaseOut
            let reset = SKAction.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    egg.removeFromParent()
                }
            }
            egg.run(.sequence([move, reset]))
        } else {
            s.emitter.addEmitter(position: egg.position)
            egg.removeAllChildren()
            egg.removeFromParent()
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
        s.fox = Fox()
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
            s.eagle = Eagle()
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

        // Handle player flap animation
        if s.player.physicsBody?.velocity == CGVector(dx: 0, dy: 0) {
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
        if s.player.physicsBody?.velocity == CGVector(dx: 0, dy: 0)
            && !s.const.gameOver
            && !s.fox.isRunning()
            && s.scoreNum > 0
            && s.const.gameDifficulty != 0 {
            spawnEnemy()
        }
    }
}
