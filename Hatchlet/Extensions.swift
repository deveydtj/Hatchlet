//
//  Extensions.swift
//  Hatchlet
//
//  Created by jake on 5/22/25.
//  Copyright © 2025 Jacob DeVeydt. All rights reserved.
//

import SpriteKit

extension SKLabelNode {
    func withShadow(offset: CGPoint = CGPoint(x: 2, y: -2), shadowColor: SKColor = .black) -> [SKLabelNode] {
        let shadowNode = SKLabelNode(fontNamed: self.fontName)
        shadowNode.text = self.text
        shadowNode.fontSize = self.fontSize
        shadowNode.fontColor = shadowColor
        shadowNode.position = CGPoint(x: self.position.x + offset.x, y: self.position.y + offset.y)
        shadowNode.zPosition = (self.zPosition - 1)
        return [shadowNode, self]
    }
}
