//
//  Menu.swift
//  Lil Jumper
//
//  Created by Admin on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit


class Menu: SKNode {
    let size: CGSize
    
    let title: SKLabelNode
    var titleShadow: SKLabelNode
    
    var shopAtlas = SKTextureAtlas()
    var playAtlas = SKTextureAtlas()
    var shopArrary = [SKTexture]()
    var playArray = [SKTexture]()
    
    
    let bin: SKSpriteNode
    
    // BUTTONS
    var playButton: SKSpriteNode
    var settingsButton: SKSpriteNode
    var shopButton: SKSpriteNode
    var crownButton: SKSpriteNode
    
    let MenuAtlas = SKTextureAtlas(named: "Menu")
    
    init(size: CGSize){
        self.size = size
        
        title = SKLabelNode(fontNamed: "AmaticSC-Regular")
        titleShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        
        shopAtlas = SKTextureAtlas(named: "images")
        playAtlas = SKTextureAtlas(named: "play")
        
        bin = SKSpriteNode(texture: nil, size: CGSize(width: 336 ,height: 400))
        
        playButton = SKSpriteNode()
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
        shopAtlas.preload {
        }
        
        playAtlas.preload {
        }
        
//        for i in 0...(shopAtlas.textureNames.count - 1) {
//            let name = "shop\(i).png"
//            shopArrary.append(SKTexture(imageNamed: name))
//        }
        
        for i in 0...(playAtlas.textureNames.count - 1) {
            let name = "playButton\(i).png"
            playArray.append(SKTexture(imageNamed: name))
        }
        
        name = "MENU"
        title.text = "Hatchlet"
        title.fontSize = 70
        title.position = CGPoint(x:0, y: 0 + title.frame.height)
        title.zPosition = 7
        title.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        titleShadow.text = title.text
        titleShadow.fontSize = 70
        titleShadow.position = CGPoint(x: title.position.x + 3, y: title.position.y - 2)
        titleShadow.zPosition = 6
        titleShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
 
        bin.texture = MenuAtlas.textureNamed("bin")
        bin.position = CGPoint(x: size.width / 2, y: size.height/1.5)
        bin.zPosition = 5
        
        playButton.texture = MenuAtlas.textureNamed("play")
        playButton.name = "playButton"
        playButton.size = CGSize(width: 87, height: 78)
        playButton.position = CGPoint(x: 0, y: 0)
        playButton.zPosition = 15
        
        
        //shopButton.texture = MenuAtlas.textureNamed(shopAtlas.textureNames[1] )
        
        playButton.texture = MenuAtlas.textureNamed(playAtlas.textureNames[1] )
        
        shopButton.texture = MenuAtlas.textureNamed("shop")
        shopButton.name = "shopButton"
        shopButton.size = CGSize(width: 58, height: 60)
        shopButton.position = CGPoint(x: 0, y: 0)
        shopButton.position = CGPoint(x: 0, y: -100)
        shopButton.zPosition = 16
        

        settingsButton.texture = MenuAtlas.textureNamed("settings")
        settingsButton.name = "settingsButton"
        settingsButton.size = CGSize(width: 58, height: 60)
        settingsButton.position = CGPoint(x: -80, y: -100)
        settingsButton.zPosition = 15
        
        
        crownButton.texture = MenuAtlas.textureNamed("crown")
        crownButton.name = "crownButton"
        crownButton.size = CGSize(width: 58, height: 60)
        crownButton.position = CGPoint(x: 80, y: -100)
        crownButton.zPosition = 15
        
        
    }
    
    func show() {
        bin.addChild(title)
        bin.addChild(titleShadow)
        bin.addChild(playButton)
        bin.addChild(shopButton)
        bin.addChild(settingsButton)
        bin.addChild(crownButton)
        addChild(bin)
        
        let animate = SKAction.animate(with: playArray, timePerFrame: 0.0084)
        
        let seq = SKAction.sequence([animate, SKAction.wait(forDuration: 0.3)])
        let seq2 = SKAction.sequence([animate, SKAction.wait(forDuration: 2.0)])
        let seq3 = SKAction.sequence([seq,seq2])
        
        playButton.run(SKAction.repeatForever(seq3))
        
        //shopButton.run(SKAction.repeatForever(SKAction.animate(with: shopArrary, timePerFrame: 0.006)))
    }
    
    func delete() {
        bin.removeAllChildren()
        removeAllActions()
        removeAllChildren()
        removeFromParent()
    }
}
