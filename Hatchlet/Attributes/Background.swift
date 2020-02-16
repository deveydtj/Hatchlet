//
//  Landscape.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class Background: SKNode {
    
    let background: SKSpriteNode
    let backgroundTexture: SKTexture
    
    let size: CGSize

// ~Init
    init(size: CGSize) {
        
        backgroundTexture = Constant.textureNamed("background")
        
        background = SKSpriteNode(texture: backgroundTexture, size: CGSize(width: size.width, height: size.height))
        
        self.size = background.size
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// ~Setup
    func setup() {
        
        addChild(background)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.blendMode = .replace
        background.zPosition = 1
        
    }
}


