//
//  Player.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//
import SpriteKit


class Player:SKSpriteNode {

    //Player Images
    var playerBlink = SKTexture()
    var playerImage = SKTexture()
    var playerFlap = SKTexture()
    var playerOuch = SKTexture()
   
    //Player Images when "sick"
    var playerBlinkSick = SKTexture()
    var playerImageSick = SKTexture()
    var playerFlapSick = SKTexture()
    var playerOuchSick = SKTexture()
    
    
    init() {
        let size = CGSize(width: 135 / 1.85, height: 118.3 / 1.85)
        
        super.init(texture: nil, color: UIColor.purple, size: size)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //SETUP
    
    func setup() {
        
        playerImage = Constant.textureNamed("bob")
        texture = playerImage
        playerBlink = Constant.textureNamed("bobBlink")
        playerBlinkSick = Constant.textureNamed("bobBlinkSick")
        playerImageSick = Constant.textureNamed("bobSick")
        playerFlap = Constant.textureNamed("bobFlap")
        playerFlapSick = Constant.textureNamed("bobFlapSick")
        playerOuch = Constant.textureNamed("bobOuch")
        playerOuchSick = Constant.textureNamed("bobOuchSick")
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody!.isDynamic = true
        physicsBody!.affectedByGravity = true
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0.9
        
        physicsBody!.categoryBitMask = PhysicsCategory.Player
        physicsBody!.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Roof
        physicsBody!.contactTestBitMask = PhysicsCategory.Egg | PhysicsCategory.Roof | PhysicsCategory.Ground | PhysicsCategory.Enemy
    
    }
    
    func flap() {
        let flap = SKAction.animate(with: [playerFlap], timePerFrame: 0.17)
        let noFlap = SKAction.animate(with: [playerImage], timePerFrame: 0.17)
        let sequence2 = SKAction.sequence([flap, noFlap])
        
        run(SKAction.sequence([
                       SKAction.run() { [weak self] in guard let `self` = self else { return }
                        if ((Int.random(in: 1...20)) == 5 ) {
                            self.quickBlink()
                        }
            }, sequence2]),withKey: "flap")
    }
    
    func hurtHead() {
        let ouch = SKAction.animate(with: [playerOuch], timePerFrame: 0.4)
        let noOuch = SKAction.animate(with: [playerImage], timePerFrame: 0)
        let sequence = SKAction.sequence([ouch, noOuch])
        run(sequence)
        
        hurt()
    }
    
    func quickBlink() {
        let ouch = SKAction.animate(with: [self.playerBlink], timePerFrame: 0.2)
        let noOuch = SKAction.animate(with: [self.playerImage], timePerFrame: 0.2)
        let sequence2 = SKAction.sequence([ouch, noOuch])
        sequence2.timingMode = SKActionTimingMode.easeInEaseOut
        
        run(SKAction.sequence([sequence2]))
        
    }
    
    func blink() {
        let ouch = SKAction.animate(with: [playerBlink], timePerFrame: 0.2)
        let noOuch = SKAction.animate(with: [playerImage], timePerFrame: 0.5)
        let sequence = SKAction.sequence([ouch, noOuch])
            
        run(SKAction.repeatForever(SKAction.sequence([sequence, SKAction.wait(forDuration: Double.random(in: 1 ... 6))])))
    }
    
    func hurt() {
        let colorize = SKAction.colorize(with: .red, colorBlendFactor: 0.4, duration: 0.1)
        let unColorize = SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
        let seq = SKAction.sequence([colorize, unColorize])
        
        run(SKAction.repeat(seq, count: 2))
    }
}
