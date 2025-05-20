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
    
    let size: CGSize

// ~Init
    init(size: CGSize) {
        
        background = SKSpriteNode(texture: nil, size: CGSize(width: size.width, height: size.height))
    
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
        background.zPosition = 1
        changeBackGround()
        background.blendMode = .replace
    }
    
    func changeBackGround() {
        let random = (Int.random(in: 1...2))
        
        if random == 1 {
            background.texture = Constant.textureNamed("night_background1")
        }
        else {
            background.texture = Constant.textureNamed("background")
        }
    }
}


