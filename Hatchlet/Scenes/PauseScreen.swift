//
//  Menu.swift
//  Lil Jumper
//
//  Created by Admin on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class PauseScreen: SKNode {
    let size: CGSize
    let play: SKSpriteNode
    let finalScore: ShadowLabelNode
    
    init(size: CGSize){
        self.size = size
        play = SKSpriteNode(texture: Constant.textureNamed("playButton"), color: .red, size: CGSize(width: 150, height: 40))
        
        finalScore = ShadowLabelNode(fontNamed: "AmaticSC-Bold", shadowOffset: CGPoint(x: 2.5, y: -1.5))
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        play.name = "playButton"
        play.zPosition = 71
        play.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        play.size = CGSize(width: 77, height: 80)
        addChild(play)
        
        finalScore.text = "Paused"
        finalScore.fontSize = 55
        finalScore.position = CGPoint(x: size.width / 2, y: size.height / 2 + finalScore.labelFrame.size.height)
        finalScore.zPosition = 72
        finalScore.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        finalScore.shadowColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(finalScore)
    }
}
