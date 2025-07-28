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
    var enemyFlap = SKTexture()
    var running:Bool = false
    
    var prevPos: CGFloat = 0
    
    init() {
        let size = CGSize(width: 207 / 1.9, height: 140 / 1.9)
        
        super.init(texture: nil, color: UIColor.purple, size: size)
        
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //SETUP
    
    func setup() {

        enemyImage = Game.textureNamed("eagle")
        enemyFlap = Game.textureNamed("eagleFlap")
        texture = enemyImage

        name = "eagle"
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.64)
        guard let body = physicsBody else { return }
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false

        body.categoryBitMask = PhysicsCategory.Enemy
        body.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Roof
        body.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Roof | PhysicsCategory.Ground

        zPosition = 101
    }
//
//    func run(speed: Double, viewSize: CGSize) {
//        running = true
//        let maxY = viewSize.height
//        let minY = viewSize.height / 2
//        let range = maxY - minY
//
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: (viewSize.width + (size.width * 1.5)),y: CGFloat(maxY) - CGFloat(arc4random_uniform(UInt32 (range)))))
//        path.addCurve(to:CGPoint(x: -size.width, y:  CGFloat(maxY) - CGFloat(arc4random_uniform(UInt32 (range)))),
//                      controlPoint1: CGPoint(x: 136, y: viewSize.height), //136, 373
//            controlPoint2: CGPoint(x: 178, y: Int.random(in: 100...400))) //178 x 110
//
//        let reset = SKAction.run() { [weak self] in guard self != nil else { return }
//            self!.stop()
//        }
//        let moveLeft = SKAction.follow(path.cgPath,
//        asOffset: false,
//        orientToPath: false,
//        speed: 250.0)
//
//        //run(SKAction.sequence([moveLeft, reset]))
//        flap()
//    }
    
    func run(speed: Double, viewSize: CGSize) {
        running = true
        let moveLeft = SKAction.moveBy(x: -(viewSize.width + (size.width * 1.5)), y: 0, duration: speed * 2)
        let reset = SKAction.run() { [weak self] in guard self != nil else { return }
            self!.stop()
        }
        run(SKAction.sequence([moveLeft, reset]))

        flap()
    }
    
    func flap() {
        let flap = SKAction.animate(with: [enemyImage], timePerFrame: 0.17)
        let noFlap = SKAction.animate(with: [enemyFlap], timePerFrame: 0.17)
        let sequence2 = SKAction.sequence([flap, noFlap])
        
         run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run() { [weak self] in guard self != nil else { return }
            }, sequence2])))
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
