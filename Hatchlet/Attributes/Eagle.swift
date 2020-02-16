//
//  Player.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//
import SpriteKit


class Eagle:SKSpriteNode {
    
    let Game = SKTextureAtlas(named: "Game")
    var enemyImage = SKTexture()
    var running:Bool = false
    
    var prevPos: CGFloat = 0
    
    init() {
        let size = CGSize(width: 207 / 1.35, height: 140 / 1.35)
        
        super.init(texture: nil, color: UIColor.purple, size: size)
        
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //SETUP
    
    func setup() {
        
        enemyImage = Game.textureNamed("eagle")
        texture = enemyImage
        
        name = "eagle"
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.64)
        physicsBody!.isDynamic = true
        physicsBody!.affectedByGravity = true
        physicsBody!.allowsRotation = false
        
        physicsBody!.categoryBitMask = PhysicsCategory.Enemy
        physicsBody!.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Roof
        physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Roof | PhysicsCategory.Ground
    }
    
    func run(speed: Double, viewSize: CGSize) {
        running = true
        let moveLeft = SKAction.moveBy(x: -(viewSize.width + (size.width * 1.5)), y: 0, duration: speed)
        let reset = SKAction.run() { [weak self] in guard self != nil else { return }
            self!.stop(viewSize: viewSize)
        }
        run(SKAction.sequence([moveLeft, reset]))
        
        let jump = SKAction.run() { [weak self] in guard self != nil else { return }
            self!.physicsBody!.applyForce(CGVector(dx: 0, dy: 1000 * Double.random(in: 1.0..<3.1)))
        }
        let wait = SKAction.wait(forDuration: 0.2)
        
        run(SKAction.repeat(SKAction.sequence([jump, wait]), count: 24))
        
    }
    
    func stop(viewSize: CGSize)
    {
        removeAllActions()
        removeAllChildren()
        removeFromParent()
        running = false
    }
    
    func isRunning() -> Bool{
        return(running)
    }
}
