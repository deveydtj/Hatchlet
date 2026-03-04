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
    private let playAnimationDuration: TimeInterval = 1.0
    
    let title: ShadowLabelNode
    
    var shopAtlas = SKTextureAtlas()
    var playAtlas = SKTextureAtlas()
    var shopArrary = [SKTexture]()
    var playArray = [SKTexture]()
    private var playAnimationAction = SKAction.wait(forDuration: 0.0)
    
    let bin: SKSpriteNode
    
    // BUTTONS
    var playButton: SKSpriteNode
    var settingsButton: SKSpriteNode
    var shopButton: SKSpriteNode
    var crownButton: SKSpriteNode
    
    let MenuAtlas = SKTextureAtlas(named: "Menu")
    
    init(size: CGSize){
        self.size = size
        
        title = ShadowLabelNode(fontNamed: "AmaticSC-Regular", shadowOffset: CGPoint(x: 3, y: -2))
        
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
        
        let targetPlayFrameCount = Self.recommendedPlayFrameCount(
            fullCount: playAtlas.textureNames.count
        )
        let sortedPlayFrameNames = sortedByFrameIndex(playAtlas.textureNames)
        let sampledPlayFrameNames = Self.sampledFrameNames(
            from: sortedPlayFrameNames,
            targetCount: targetPlayFrameCount
        )
        playArray = sampledPlayFrameNames.map { playAtlas.textureNamed($0) }
        
        name = "MENU"
        title.text = "Hatchlet"
        title.fontSize = 70
        title.position = CGPoint(x: 0, y: title.labelFrame.height)
        title.zPosition = 7
        title.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        title.shadowColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
        bin.position = CGPoint(x: size.width / 2, y: size.height/1.5)
        bin.zPosition = 5
        
        playButton.texture = MenuAtlas.textureNamed("play")
        playButton.name = "playButton"
        playButton.size = CGSize(width: 87, height: 78)
        playButton.position = CGPoint(x: 0, y: 0)
        playButton.zPosition = 15
        
        if let firstFrame = playArray.first {
            playButton.texture = firstFrame
        }
        
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
        
        // Add menu nodes once during setup
        addChild(bin)
        addChild(title)
        addChild(playButton)
        addChild(shopButton)
        addChild(settingsButton)
        addChild(crownButton)
        
        if playArray.count > 1 {
            let frameDuration = playAnimationDuration / Double(playArray.count)
            let animate = SKAction.animate(with: playArray, timePerFrame: frameDuration, resize: false, restore: false)
            let intro = SKAction.sequence([animate, SKAction.wait(forDuration: 0.3)])
            let loop = SKAction.sequence([animate, SKAction.wait(forDuration: 2.0)])
            playAnimationAction = SKAction.repeatForever(SKAction.sequence([intro, loop]))
        } else {
            playAnimationAction = SKAction.wait(forDuration: 0.0)
        }
    }
    
    func show() {
        if playArray.count > 1, playButton.action(forKey: "menuPlayAnimation") == nil {
            playButton.run(playAnimationAction, withKey: "menuPlayAnimation")
        }
        //shopButton.run(SKAction.repeatForever(SKAction.animate(with: shopArrary, timePerFrame: 0.006)))
    }
    
    func hide() {
        bin.removeAllChildren()
        removeAllActions()
        removeAllChildren()
        removeFromParent()
    }
    
    private static func sampledFrameNames(from textureNames: [String], targetCount: Int) -> [String] {
        guard !textureNames.isEmpty else { return [] }

        guard targetCount > 1 else {
            return targetCount == 1 ? [textureNames[0]] : []
        }

        guard textureNames.count > targetCount else { return textureNames }

        let lastIndex = textureNames.count - 1
        let step = Double(lastIndex) / Double(targetCount - 1)

        var indices: [Int] = []
        indices.reserveCapacity(targetCount)

        for i in 0..<targetCount {
            var index = Int(round(Double(i) * step))
            if let last = indices.last, index <= last {
                index = min(last + 1, lastIndex)
            }
            indices.append(index)
        }

        return indices.map { textureNames[$0] }
    }
    
    private static func recommendedPlayFrameCount(fullCount: Int) -> Int {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            return 1
        }

        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        if physicalMemory >= 5_000_000_000 {
            return fullCount
        }
        if physicalMemory >= 4_000_000_000 {
            return min(24, fullCount)
        }
        return min(12, fullCount)
    }
}
