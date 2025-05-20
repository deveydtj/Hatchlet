//
//  Settings.swift
//  Lil Jumper
//
//  Created by CodableSheep on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit


class Tut: SKNode {
    
    let size: CGSize
    
    let bin: SKSpriteNode
    
    let tut:SKSpriteNode
    
    let title: SKLabelNode
    var titleShadow: SKLabelNode
    
    var tutAtlas = SKTextureAtlas()
    var tutArray = [SKTexture]()
    
    init(size: CGSize){
        self.size = size
        
        title = SKLabelNode(fontNamed: "AmaticSC-Regular")
        titleShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        
        bin = SKSpriteNode(texture: nil, size: CGSize(width: 336 ,height: 400))
        
        tutAtlas = SKTextureAtlas(named: "tut")
        
        tut = SKSpriteNode()
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        tutAtlas.preload {
        }
        
        for i in 0...(tutAtlas.textureNames.count - 1) {
            let name = "tutorial\(i).png"
            tutArray.append(SKTexture(imageNamed: name))
        }
        
    
        tut.texture = tutAtlas.textureNamed(tutAtlas.textureNames[1])
        tut.name = "tut"
        tut.size = CGSize(width: 80, height: 122)
        tut.position = CGPoint(x: 0, y: 0)
        tut.zPosition = 51
        
        title.text = "tap to flap"
        title.fontSize = 50
        title.position = CGPoint(x:0, y: 0 - tut.size.height)
        title.zPosition = 52
        title.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
        titleShadow.text = title.text
        titleShadow.fontSize = title.fontSize
        titleShadow.position = CGPoint(x: title.position.x + 2, y: title.position.y - 1)
        titleShadow.zPosition = 51
        titleShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
        bin.position = CGPoint(x: size.width / 2, y: size.height/1.5)
        bin.zPosition = 20
    
    }
    
    func show() {
        bin.addChild(title)
        bin.addChild(titleShadow)
        tut.removeAllActions()
        bin.addChild(tut)
        bin.alpha = 0.75
        addChild(bin)


        let animate = SKAction.animate(with: tutArray, timePerFrame: 0.0125)
        
        let seq = SKAction.sequence([animate, SKAction.wait(forDuration: 0.15)])
        let seq2 = SKAction.sequence([animate, SKAction.wait(forDuration: 2.0)])
        let seq3 = SKAction.sequence([seq,seq2])
        
        tut.run(SKAction.repeatForever(seq3))
        
    }
    
    func delete() {
        bin.run(SKAction.fadeOut(withDuration: 0.56))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.bin.removeAllChildren()
            self.bin.removeAllActions()
            self.removeAllActions()
            self.removeAllChildren()
            self.removeFromParent()
        }

    }
}
