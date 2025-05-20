//
//  Utility.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation
import SpriteKit

class gameHUD: SKNode {
    
    let size:CGSize

    var score: Int! = 0
    var scoreLabel = SKLabelNode()
    var labelShadow = SKLabelNode()
    
    let emitter:Emitters
    
    let goldenEgg: SKSpriteNode
    let goldenEggTexture: SKTexture
    
    let eggDelete: SKSpriteNode
    
    let Game = SKTextureAtlas(named: "Game")
    
    var playerShadowTexture = SKTexture()
    let playerShadow: SKSpriteNode
    let enemyShadow: SKSpriteNode
    var prevPos: CGFloat = 0
    
    var numLifes: Int = 3
    let livesNode: SKNode
    var playerLifes = [Life]()
    
    
    init(size: CGSize, player: SKNode){
        self.size = size
        
        goldenEggTexture = Game.textureNamed("goldenEgg")
        goldenEgg = Egg()
        
        emitter = Emitters(size: size)
        scoreLabel = SKLabelNode()
        labelShadow = SKLabelNode()
        
        playerShadowTexture = Game.textureNamed("shadow")
        
        eggDelete = SKSpriteNode(texture: nil, color: UIColor .red, size: CGSize(width: 40, height: size.height))
        
        livesNode = SKNode()
        
        playerShadow = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: 40, height: 10))
        enemyShadow = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: 60, height: 10))
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// ~Setup
    func setup(){
        
        addChild(livesNode)
        setupLives()
        livesNode.position.x = size.width / 3.7
             
// ~Add Score Label
        addChild(scoreLabel)
        scoreLabel.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        scoreLabel.fontSize = 55
        scoreLabel.fontName = "AmaticSC-Bold"
        scoreLabel.text = String(score)
        scoreLabel.position.x = (size.width / 2) + scoreLabel.frame.width + 30
        scoreLabel.position.y = size.height - 60
        scoreLabel.zPosition = 20
        
        addChild(labelShadow)
        labelShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        labelShadow.fontSize = 55
        labelShadow.fontName = scoreLabel.fontName
        labelShadow.text = scoreLabel.text
        labelShadow.position.x = (scoreLabel.position.x) + 3
        labelShadow.position.y = (scoreLabel.position.y) - 2
        labelShadow.zPosition = 19
        
// ~Add Egg Deleter
        addChild(eggDelete)
        eggDelete.position.x = size.width / 2
        eggDelete.position.y = size.height / 2
        eggDelete.physicsBody = SKPhysicsBody(rectangleOf: eggDelete.size)
        
        eggDelete.physicsBody!.isDynamic = true
        eggDelete.physicsBody!.affectedByGravity = false
        eggDelete.physicsBody!.allowsRotation = false
        
        eggDelete.physicsBody!.categoryBitMask = PhysicsCategory.eggDelete
        eggDelete.physicsBody!.collisionBitMask = PhysicsCategory.Player
        eggDelete.physicsBody!.contactTestBitMask = PhysicsCategory.Egg
        
// ~Add Golden Egg
        addChild(goldenEgg)
        goldenEgg.position = CGPoint(x: size.width / 2 + goldenEgg.size.width, y: scoreLabel.position.y - scoreLabel.frame.size.height - goldenEgg.size.height)
        goldenEgg.alpha = 0.1
        goldenEgg.scale(to: CGSize(width: 0.1, height: 0.1))
        goldenEgg.physicsBody = nil
        goldenEgg.texture = goldenEggTexture
        
        
        playerShadow.position.y = 48
        playerShadow.zPosition = 98
        playerShadow.texture = playerShadowTexture
        playerShadow.alpha = 0.60
        addChild(playerShadow)
        
        enemyShadow.position.y = 48
        enemyShadow.zPosition = 98
        enemyShadow.texture = playerShadowTexture
        enemyShadow.alpha = 0.60
        addChild(enemyShadow)
        enemyShadow.isHidden = true
    }
    
//******************************************************************************
// ~Add Lives
    func setupLives() {

        livesNode.removeAllChildren()
        
        for i in 0..<3 {
            let playerLife = Life()
            playerLife.name = "life" + String(i)
            playerLife.position.x = (size.width + (35*CGFloat(i)))
            playerLife.position.y = size.height - 55
            
            playerLifes.append(playerLife)
            livesNode.addChild(playerLife)
        }
    }
    
//******************************************************************************
//~Remove Life
    func removeLife() -> Bool{
        var lifesLeft = true
        if numLifes > 1 {
            numLifes -= 1
            playerLifes[numLifes].isHidden = true
            
        }
        else {
            lifesLeft = false
            numLifes -= 1
            playerLifes[numLifes].isHidden = true
        }
        return(lifesLeft)
    }
    
//******************************************************************************
//~Remove Life
    func addLife(howMany: Int = 1) {
        
        if (numLifes + (howMany)) <= 3 {
            for _ in 1...howMany {
                playerLifes[numLifes].isHidden = false
                numLifes += 1
            }
        }
    }
    
//******************************************************************************
//~Update Shadow
    func updateShadow (userOfShadow: String, currentPos: CGFloat) {
        
        let maxShadowSize = CGFloat(60)
        let minShadowSize = CGFloat(2)
        
        let maxY:CGFloat = 400
        let minY:CGFloat = 50
        //WARNING CHECK THIS ^^^^^^^^
        
        var percentChange: CGFloat = 0
        
        if userOfShadow == "player"
        {
            if currentPos < maxY { //player is less than maxY
                percentChange = (maxY - currentPos) / (maxY - minY)
                playerShadow.size.width = percentChange * (maxShadowSize - minShadowSize)
            }
            else {
                playerShadow.size.width = 0
            }
            prevPos = currentPos
        }
        else {
            if currentPos < maxY { //player is less than maxY
                percentChange = (maxY - currentPos) / (maxY - minY)
                enemyShadow.size.width = percentChange * (maxShadowSize - minShadowSize)
            }
            else {
                enemyShadow.size.width = 0
            }
            prevPos = currentPos
            
        }
    }
    
    func goldenEggUpdate1() {
        goldenEgg.alpha = 1
        goldenEgg.scale(to: CGSize(width: 30,height:35))
    }
    
    func goldenEggUpdate() {
        let wait = SKAction.wait(forDuration: 1.9)
        let upScale = SKAction.scale(to: 1, duration: 0.25)
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let sequence1 = SKAction.sequence([upScale, fadeIn])
        
        goldenEgg.run(sequence1)
        
        let downScale = SKAction.scale(to: 0.1, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let sequence2 = SKAction.sequence([downScale, fadeOut])
        let seq = SKAction.sequence([wait,sequence2])

        goldenEgg.run(seq)
    }
}
