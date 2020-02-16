//
//  Settings.swift
//  Lil Jumper
//
//  Created by CodableSheep on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit


class Crown: SKNode {
    
    let size: CGSize
    
    let title: SKLabelNode
    var titleShadow: SKLabelNode
    
    let highScore: SKLabelNode
    var highScoreShadow: SKLabelNode
    
    let bin: SKSpriteNode
    
    // BUTTONS
    var backButton: SKSpriteNode
    var settingsButton: SKSpriteNode
    var shopButton: SKSpriteNode
    var crownButton: SKSpriteNode
    
    let MenuAtlas = SKTextureAtlas(named: "Menu")
    
    init(size: CGSize){
        self.size = size
        
        title = SKLabelNode(fontNamed: "AmaticSC-Regular")
        titleShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        
        highScore = SKLabelNode(fontNamed: "AmaticSC-Regular")
        highScoreShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        
        bin = SKSpriteNode(texture: nil, size: CGSize(width: 336 ,height: 400))
        
        backButton = SKSpriteNode()
        settingsButton = SKSpriteNode()
        shopButton = SKSpriteNode()
        crownButton = SKSpriteNode()

        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        title.text = "Achievements"
        title.fontSize = 70
        title.position = CGPoint(x:0, y: 0 + title.frame.height)
        title.zPosition = 7
        title.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        titleShadow.text = title.text
        titleShadow.fontSize = 70
        titleShadow.position = CGPoint(x: title.position.x + 3, y: title.position.y - 2)
        titleShadow.zPosition = 6
        titleShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
        highScore.fontSize = 35
        highScore.position = CGPoint(x:0, y: -20)
        highScore.zPosition = 7
        highScore.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        highScoreShadow.fontSize = highScore.fontSize
        highScoreShadow.position = CGPoint(x: highScore.position.x + 2, y: highScore.position.y - 1)
        highScoreShadow.zPosition = 6
        highScoreShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
        highScore.text = "HighScore: " + String(UserDefaults.standard.integer(forKey: "highScore"))
        highScoreShadow.text = highScore.text

        bin.texture = MenuAtlas.textureNamed("bin")
        bin.position = CGPoint(x: size.width / 2, y: size.height/1.5)
        bin.zPosition = 5
        
        backButton.texture = Constant.textureNamed("mainMenu")
        backButton.name = "crownBackButton"
        backButton.size = CGSize(width: 58, height: 60)
        backButton.position = CGPoint(x: -120, y: 140)
        backButton.zPosition = 15
    }
    
    func show() {
        highScore.text = "HighScore: " + String(UserDefaults.standard.integer(forKey: "highScore"))
        highScoreShadow.text = highScore.text
        
        bin.addChild(title)
        bin.addChild(titleShadow)
        bin.addChild(highScore)
        bin.addChild(highScoreShadow)
        bin.addChild(backButton)
        addChild(bin)
    }
    
    func delete() {
        bin.removeAllChildren()
        removeAllActions()
        removeAllChildren()
        removeFromParent()
    }
}
