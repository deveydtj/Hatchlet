//
//  Egg.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class Life: SKSpriteNode {
    
    var heart = SKTexture()
    
    let Game = SKTextureAtlas(named: "Game")
    
    init() {
        let heartSize = CGSize(width: 65 / 2, height: 66 / 2)
        super.init(texture: nil, color: UIColor.red, size: heartSize)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //SETUP
    
    func setup() {
        heart = Game.textureNamed("heart")
        texture = heart
        
        zPosition = 100
    }
}
