//
//  Menu.swift
//  Lil Jumper
//
//  Created by Admin on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class EndScreen: SKNode {
    let size: CGSize
    var score: Int
    let menu: SKSpriteNode
    let finalScore: SKLabelNode
    let finalScoreShadow: SKLabelNode

    var menuTexture = SKTexture()
    
    init(size: CGSize, score: Int){
        self.size = size
        self.score = score
        menu = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 150, height: 40))
        
        finalScore = SKLabelNode(fontNamed: "AmaticSC-Bold")
        finalScoreShadow = SKLabelNode(fontNamed: finalScore.fontName)
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        menuTexture = Constant.textureNamed("mainMenu")
        
        menu.name = "menu"
        menu.zPosition = 71
        menu.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        menu.size = CGSize(width: 77, height: 80)
        menu.texture = menuTexture
        addChild(menu)
        
        finalScore.text = "Your Score: " + String(score)
        finalScore.fontSize = 55
        finalScore.position = CGPoint(x: size.width / 2, y: size.height / 2 + (finalScore.frame.size.height))
        finalScore.zPosition = 72
        finalScore.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        addChild(finalScore)
        
        finalScoreShadow.text = "Your Score: " + String(score)
        finalScoreShadow.fontSize =  finalScore.fontSize
        finalScoreShadow.position = CGPoint(x:  finalScore.position.x + 2.5, y:  finalScore.position.y - 1.5)
        finalScoreShadow.zPosition = 71
        finalScoreShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(finalScoreShadow)
        
    }
}
