//
//  Landscape.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import SpriteKit


class Landscape: SKNode {
    
    let ground: Ground
    let roof: Roof
    let foreground: SKSpriteNode
    
    let size: CGSize
    
// ~Init
    init(size: CGSize) {
        self.size = size
        
        foreground = SKSpriteNode(color: .clear, size: size)
        
        ground = Ground(size: CGSize(width: size.width, height: 40))
        roof = Roof(size: CGSize(width: size.width, height: 1))
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// ~Setup
    
    func setup() {
        
        addChild(foreground)
        foreground.anchorPoint = CGPoint(x: 0, y: 0)
        
        // ~Add Ground
        addChild(ground)
        ground.position.x = size.width / 2
        ground.position.y = ground.size.height / 2
        ground.zPosition = 3
        
        // ~Add Roof
        addChild(roof)
        roof.position.x = size.width / 2
        roof.position.y = size.height + roof.size.height * 2
        
    }
    
    func resetLandscape() {
        //foreground.color = randomColor()
    }
}


