//
//  Ground.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import SpriteKit


class Roof:SKSpriteNode {
    
    init(size: CGSize) {
        let roofSize = CGSize(width: size.width, height: max(size.height, 8))
        
        super.init(texture: nil, color: .clear, size: roofSize)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ~Setup
    
    func setup() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody!.isDynamic = false
        
        physicsBody!.categoryBitMask = PhysicsCategory.Roof
        physicsBody!.collisionBitMask = PhysicsCategory.Player
        physicsBody!.contactTestBitMask = PhysicsCategory.None
        //change contact test to add feather emitter
    }
}
