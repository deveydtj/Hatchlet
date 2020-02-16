//
//  Landscape.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class Parallax: SKNode {
    
    let parallaxBG: SKSpriteNode
    let parallaxTexture: SKTexture
    
    let size: CGSize

// ~Init
    init(size: CGSize) {
        
        parallaxTexture = Constant.textureNamed("mountains")
        
        parallaxBG = SKSpriteNode(texture: parallaxTexture, size: CGSize(width: size.width * 3, height: size.height / 3))
        
        self.size = parallaxBG.size
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// ~Setup
    func setup() {
        
        addChild(parallaxBG)
        parallaxBG.anchorPoint = CGPoint(x: 0, y: 0)
        parallaxBG.zPosition = 2
        
    }
}


