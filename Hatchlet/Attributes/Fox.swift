//
//  Player.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//
import SpriteKit


class Fox:SKSpriteNode {
    
    let Game = SKTextureAtlas(named: "Game")
    var enemyImage = SKTexture()
    var running:Bool = false
    
    var prevPos: CGFloat = 0
    
    init() {
        let size = CGSize(width: 135 / 1.25, height: 118.3 / 1.25)
        
        super.init(texture: nil, color: UIColor.purple, size: size)
        
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //SETUP
    
    func setup() {
        
        enemyImage = Game.textureNamed("fox")
        texture = enemyImage
        
        name = "fox"
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.15)
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
            self!.stop()
        }
        run(SKAction.sequence([moveLeft, reset]))
        
        
        
        let jump = SKAction.run() { [weak self] in guard self != nil else { return }
            self!.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 90 * Double.random(in: 1.5..<3.0)))
        }
        let wait = SKAction.wait(forDuration: 2)
        
        run(SKAction.repeat(SKAction.sequence([jump, wait]), count: 4))
        
    }
    
    func stop()
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
