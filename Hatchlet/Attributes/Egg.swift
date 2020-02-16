//
//  Egg.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class Egg: SKSpriteNode {
    
    var eggTexture = SKTexture()
    var goldenEggTexture = SKTexture()
    var rottenEggTexture = SKTexture()
    
   var isGoldenEgg:Bool
    
    let Game = SKTextureAtlas(named: "Game")
    
    init(isGold: Bool = false) {
        let eggSize = CGSize(width: 60 / 2, height: 70 / 2)
       
        isGoldenEgg = isGold
        
        super.init(texture: nil, color: .yellow, size: eggSize)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //SETUP
    
    func setup() {
        
        eggTexture = Game.textureNamed("egg")
        
        
        if isGoldenEgg {
            goldenEggTexture = Game.textureNamed("goldenEgg")
            texture = goldenEggTexture
            name = "GoldenEgg"
            
        } else {
            texture = eggTexture
            name = "egg"
        }
    
        zPosition = 98
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody!.categoryBitMask = PhysicsCategory.Egg
        physicsBody!.collisionBitMask = PhysicsCategory.eggDelete
        physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.eggDelete | PhysicsCategory.Enemy
        physicsBody!.isDynamic = false
    }
}
