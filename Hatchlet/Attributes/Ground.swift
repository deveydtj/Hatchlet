//
//  Ground.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import SpriteKit


class Ground:SKSpriteNode {
    
    let groundTexture: SKTexture
    
    init(size: CGSize) {
        groundTexture = Constant.textureNamed("grass")
        
        let groundSize = CGSize(width: size.width, height: 90)
        
        super.init(texture: groundTexture, color: UIColor .brown, size: groundSize)
    
        zPosition = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
