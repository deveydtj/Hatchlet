//
//  Settings.swift
//  Lil Jumper
//
//  Created by CodableSheep on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//


import SpriteKit

class Settings: SKNode {
    
    // Use shared constants instance
    var constants = Constants.shared
    
    let size: CGSize
    
    let title: SKLabelNode
    var titleShadow: SKLabelNode
    
    let tutorial: SKLabelNode
    var tutorialShadow: SKLabelNode
    
    let bin: SKSpriteNode
    
    var eggSwitchAtlas = SKTextureAtlas()
    var eggSwitchArray = [SKTexture]()

    var gameDiffArray = [SKTexture]()
    
    // BUTTONS
    var backButton: SKSpriteNode
    var eggSwitch: SKSpriteNode
    var gameDiff: SKSpriteNode
    
    let MenuAtlas = SKTextureAtlas(named: "Menu")
    
    init(size: CGSize){
        self.size = size
        
        title = SKLabelNode(fontNamed: "AmaticSC-Regular")
        titleShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        tutorial = SKLabelNode(fontNamed: "AmaticSC-Regular")
        tutorialShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        
        
        bin = SKSpriteNode(texture: nil, size: CGSize(width: 336 ,height: 400))
        
        backButton = SKSpriteNode()
        
        eggSwitch = SKSpriteNode()
        eggSwitchAtlas = SKTextureAtlas(named: "eggSwitch")
        
        gameDiff = SKSpriteNode()
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        eggSwitchAtlas.preload {
        }
        
        for i in 0...(eggSwitchAtlas.textureNames.count - 1) {
                   let name = "eggSwitch\(i).png"
                   eggSwitchArray.append(SKTexture(imageNamed: name))
               }
        
//        for i in 0...(gameDiffAtlas.textureNames.count - 1) {
//                   let name = "gameDiff\(i).png"
//                   gameDiffArray.append(SKTexture(imageNamed: name))
//               }
        
        eggSwitch.texture = eggSwitchAtlas.textureNamed(eggSwitchAtlas.textureNames[1] )
        eggSwitch.name = "eggSwitchTutorial"
        eggSwitch.size = CGSize(width: 132.6, height: 41.05)
        eggSwitch.position = CGPoint(x: 72, y: 14)
        eggSwitch.zPosition = 15
        
        if constants.gameDifficulty == 0 {
            gameDiff.texture = MenuAtlas.textureNamed("gameDiff0")
        }
        else if constants.gameDifficulty == 1 {
            gameDiff.texture = MenuAtlas.textureNamed("gameDiff20")
        }
        else {
            gameDiff.texture = MenuAtlas.textureNamed("gameDiff59")
        }
        gameDiff.name = "gameDiff"
        gameDiff.size = CGSize(width: 234, height: 51.6)
        gameDiff.position = CGPoint(x: 0, y: -60)
        gameDiff.zPosition = 15
        
        
        title.text = "Settings"
        title.fontSize = 70
        title.position = CGPoint(x:0, y: 0 + title.frame.height)
        title.zPosition = 7
        title.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        titleShadow.text = title.text
        titleShadow.fontSize = 70
        titleShadow.position = CGPoint(x: title.position.x + 3, y: title.position.y - 2)
        titleShadow.zPosition = 6
        titleShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
        tutorial.text = "Tutorial"
        tutorial.fontSize = 43
        tutorial.position = CGPoint(x: -85, y: 0)
        tutorial.zPosition = 7
        tutorial.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        tutorialShadow.text = tutorial.text
        tutorialShadow.fontSize = tutorial.fontSize
        tutorialShadow.position = CGPoint(x: tutorial.position.x + 2, y: tutorial.position.y - 1)
        tutorialShadow.zPosition = 6
        tutorialShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
 
        //bin.texture = MenuAtlas.textureNamed("bin")
        bin.position = CGPoint(x: size.width / 2, y: size.height/1.5)
        bin.zPosition = 5
        
        backButton.texture = Constant.textureNamed("mainMenu")
        backButton.name = "settingsBackButton"
        backButton.size = CGSize(width: 58, height: 60)
        backButton.position = CGPoint(x: -120, y: 140)
        backButton.zPosition = 15
        
    }
    
    func show() {
        bin.addChild(title)
        bin.addChild(titleShadow)
        bin.addChild(tutorial)
        bin.addChild(tutorialShadow)
        bin.addChild(backButton)
        bin.addChild(eggSwitch)
        animateSwitch()
        bin.addChild(gameDiff)
        addChild(bin)
    }
    
    func switchButton() {
        if constants.gameTutorialOn {
            constants.setGameTut(value: false)
            eggSwitch.texture = eggSwitchAtlas.textureNamed(eggSwitchAtlas.textureNames[0] )
            let animate = SKAction.animate(with: eggSwitchArray.reversed(), timePerFrame: 0.0084)
            eggSwitch.run(animate)
        } else {
            constants.setGameTut(value: true)
            eggSwitch.texture = eggSwitchAtlas.textureNamed(eggSwitchAtlas.textureNames[55] )
            let animate = SKAction.animate(with: eggSwitchArray, timePerFrame: 0.0084)
            eggSwitch.run(animate)
        }
    }
    
    func animateSwitch() {
        if !constants.gameTutorialOn {
            eggSwitch.texture = eggSwitchAtlas.textureNamed(eggSwitchAtlas.textureNames[0] )
            let animate = SKAction.animate(with: eggSwitchArray.reversed(), timePerFrame: 0.0084)
            eggSwitch.run(animate)
        } else {
            eggSwitch.texture = eggSwitchAtlas.textureNamed(eggSwitchAtlas.textureNames[51] )
            let animate = SKAction.animate(with: eggSwitchArray, timePerFrame: 0.0084)
            eggSwitch.run(animate)
        }
    }
    
    func switchGameDiff() {
        if constants.gameDifficulty == 0 {
            constants.setGameMode(value: 1)
            gameDiff.texture = MenuAtlas.textureNamed("gameDiff20")
        }
        else if constants.gameDifficulty == 1 {
            constants.setGameMode(value: 2)
            gameDiff.texture = MenuAtlas.textureNamed("gameDiff59")
        }
        else {
            constants.setGameMode(value: 0)
            gameDiff.texture = MenuAtlas.textureNamed("gameDiff0")
        }
        gameDiff.texture!.filteringMode = .linear
    }
    
    func delete() {
        bin.removeAllChildren()
        removeAllActions()
        removeAllChildren()
        removeFromParent()
    }
}
