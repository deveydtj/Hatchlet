//
//  GameScene.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Updated for manager refactor on 05/17/2025.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//

import Foundation
import SpriteKit

let Constant = SKTextureAtlas(named: "Constant")

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /// Refreshes and animates the golden-egg label
    func updateGoldenEggDisplay() {
        guard let eggLabel = childNode(withName: "goldenEggsLabel") as? SKLabelNode else { return }
        eggLabel.text = "\(const.goldenEggs)"
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        eggLabel.run(pulse)
    }

    // MARK: - Managers
    var inputManager: InputManager!
    var gameLogic: GameLogic!
    var contactHandler: PhysicsContactHandler!
    var scrollingManager: ScrollingManager!

    // MARK: - Constants
    var const = Constants.shared

    // MARK: - Scene Nodes & State
    var scoreNum: Int = 0
    var menu: Menu
    let settings: Settings
    let shop: Shop
    let crown: Crown
    var endScreen: EndScreen
    var pauseScreen: PauseScreen
    var HUD: gameHUD
    let tut: Tut

    var trailEmitter: SKEmitterNode
    let emitter: Emitters
    let player: Player
    var eagle: Eagle
    var fox: Fox
    var pauseButton: SKSpriteNode

    let GameAtlas = SKTextureAtlas(named: "Game")
    let MenuAtlas = SKTextureAtlas(named: "Menu")

    let background: Background
    let groundHitBox: SKSpriteNode

    var landscapeBin: SKNode
    var landscape1: Landscape
    var landscape2: Landscape

    var scrollingGroundBin: SKNode
    var scrollingGround: Parallax
    var scrollingGround1: Parallax

    var gameSpeed: Double = 7
    var eggSpeed: Double = 50
    var randomMax: Int = 26
    var eagleSpeed: Double = 0.007

    var playerVelocity = CGVector.zero

    var location = CGPoint.zero
    var touched: Bool = false
    var isTouching: Bool = false
    var prevTouchedNode = SKNode()

    var newPaused: Bool = false {
        didSet {
            self.isPaused = newPaused
        }
    }
    override var isPaused: Bool {
        didSet {
            if !self.isPaused && newPaused {
                self.isPaused = true
            }
        }
    }

    // MARK: - Init

    override init(size: CGSize) {
        // Instantiate all nodes
        endScreen = EndScreen(size: size, score: scoreNum)
        pauseScreen = PauseScreen(size: size)
        menu = Menu(size: size)
        settings = Settings(size: size)
        shop = Shop(size: size, constants: const)
        crown = Crown(size: size)
        tut = Tut(size: size)

        pauseButton = SKSpriteNode(texture: Constant.textureNamed("playButton"),
                                   color: .red,
                                   size: CGSize(width: 77, height: 80))

        trailEmitter = SKEmitterNode()
        player = Player()
        eagle = Eagle()
        fox = Fox()
        HUD = gameHUD(size: size, player: player)
        emitter = Emitters(size: size)

        background = Background(size: size)
        groundHitBox = SKSpriteNode(color: .clear,
                                    size: CGSize(width: size.width * 3, height: 2))

        landscapeBin = SKNode()
        landscape1 = Landscape(size: size)
        landscape2 = Landscape(size: size)

        scrollingGroundBin = SKNode()
        scrollingGround = Parallax(size: size)
        scrollingGround1 = Parallax(size: size)

        super.init(size: size)

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.81)
        physicsWorld.contactDelegate = self

        // Initialize managers
        inputManager = InputManager(scene: self)
        gameLogic = GameLogic(scene: self)
        contactHandler = PhysicsContactHandler(scene: self)
        scrollingManager = ScrollingManager(scene: self)

        // Initial setup via GameLogic
        gameLogic.setup()

        // Observe app background notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    @objc private func appMovedToBackground() {
        if !newPaused && !const.gameOver {
            gameLogic.showPauseScreen()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Center the menu and bring it to front
        menu.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        menu.zPosition = 100
        // Show the main menu when the scene appears
        if menu.parent == nil {
            addChild(menu)
            menu.show()
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.touchesEnded(touches, with: event)
    }

    // MARK: - Physics Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        contactHandler.didBegin(contact)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        contactHandler.didEnd(contact)
    }

    // MARK: - Frame Update

    override func update(_ currentTime: TimeInterval) {
        scrollingManager.update(currentTime: currentTime)
        gameLogic.update(currentTime: currentTime)
    }
}
