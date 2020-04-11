//
//  Settings.swift
//  Lil Jumper
//
//  Created by CodableSheep on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

// Helpers:
extension SKNode {
  func addChildren(_ nodes: [SKNode]) { for node in nodes { addChild(node) } }

//  func addChildrenBehind(_ nodes: [SKNode]) { for node in nodes {
//    node.zPosition -= 2
//    addChild(node)                        THIS WILL BE REDONE!
//    }
//  }
}

class Shop: SKNode {
    
    let size: CGSize
    
    let title: SKLabelNode
    var titleShadow: SKLabelNode
    
    let bin: SKSpriteNode
    let bin1: SKSpriteNode
    let bin2: SKSpriteNode
    let bin3: SKSpriteNode
    
    // BUTTONS
    var backButton: SKSpriteNode
    var settingsButton: SKSpriteNode
    var shopButton: SKSpriteNode
    var crownButton: SKSpriteNode
    
    var leftButton: SKSpriteNode
    var rightButton: SKSpriteNode
    
    let MenuAtlas = SKTextureAtlas(named: "Menu")
    
    var availableItems: [Item] = [Item.list.blank, Item.list.gangster, Item.list.covid, Item.list.glasses, Item.list.cow, Item.list.unicorn]
    
    
    var currentPageNum = 1
    var currentPageEnd = 0
    var currentPageStart = 0
    
    
    init(size: CGSize){
        self.size = size
        
        title = SKLabelNode(fontNamed: "AmaticSC-Regular")
        titleShadow = SKLabelNode(fontNamed: "AmaticSC-Regular")
        
        bin = SKSpriteNode(texture: nil, size: CGSize(width: 336 ,height: 600))
        
        bin1 = SKSpriteNode(texture: nil, size: CGSize(width: bin.size.width - 55 ,height: 90))
        bin2 = SKSpriteNode(texture: nil, size: bin1.size)
        bin3 = SKSpriteNode(texture: nil, size: bin1.size)
        
        backButton = SKSpriteNode()
        settingsButton = SKSpriteNode()
        shopButton = SKSpriteNode()
        crownButton = SKSpriteNode()
        
        leftButton = SKSpriteNode(color: .purple, size: CGSize(width: 75, height: 75))
        rightButton = SKSpriteNode(color: .black, size: CGSize(width: 75, height: 75))
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        title.text = "Shop"
        title.fontSize = 70
        title.position = CGPoint(x:0, y: bin.size.height / 3)
        title.zPosition = 7
        title.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        titleShadow.text = title.text
        titleShadow.fontSize = 70
        titleShadow.position = CGPoint(x: title.position.x + 3, y: title.position.y - 2)
        titleShadow.zPosition = 6
        titleShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        
//----------------
        bin.texture = MenuAtlas.textureNamed("bin")
        bin.position = CGPoint(x: size.width / 2, y: size.height/1.771)
        bin.zPosition = 5
        
        bin1.zPosition = 6
        bin2.zPosition = bin1.zPosition
        bin3.zPosition = bin1.zPosition
        
        bin1.position = CGPoint(x: -10, y: 35)
        bin2.position = CGPoint(x:  bin1.position.x, y: bin1.position.y - bin1.size.height - 20)
        bin3.position = CGPoint(x: bin1.position.x, y: bin2.position.y - bin1.size.height - 20)
 
//----------------
        
        backButton.texture = Constant.textureNamed("mainMenu")
        backButton.name = "shopBackButton"
        backButton.size = CGSize(width: 58, height: 60)
        backButton.position = CGPoint(x: -120, y: bin.size.height / 3)
        backButton.zPosition = 15
        
        leftButton.zPosition = 7
        rightButton.zPosition = 7
        leftButton.name = "leftButton"
        rightButton.name = "rightButton"
        leftButton.position = CGPoint(x: -bin.size.width*0.25, y: -bin.size.height/2)
        rightButton.position = CGPoint(x: bin.size.width*0.25, y: -bin.size.height/2)
        
    }
    
    func show() {
        showPage()
        bin.addChild(leftButton)
        bin.addChild(rightButton)
        bin.addChild(title)
        bin.addChild(titleShadow)
        bin.addChild(backButton)
        addChild(bin)
    }
    
    func delete() {
        currentPageNum = 1
        pageClear()
        bin.removeAllChildren()
        removeAllActions()
        removeAllChildren()
        removeFromParent()
    }
    
    func showPage(pageNum: Int = 1) {
        var count = 0
        
        bin.addChild(bin1)
        bin.addChild(bin2)
        bin.addChild(bin3)
        //create loop
        var bin1Count = 0
        var bin2Count = 0
        var bin3Count = 0
        
        currentPageStart = 0
        currentPageEnd = 0
        
        currentPageEnd = (pageNum * 12) - 1
        currentPageStart = (currentPageEnd - 12) + 1
        
        if availableItems.count >= currentPageEnd {
            while count < 12 && currentPageStart < availableItems.count {
                let temp = createItem(numItem: currentPageStart)
                count += 1
                       if bin1Count < 4 {
                           temp.position.x = -(bin1.size.width/2) + 50
                           temp.position.x += CGFloat((Int(temp.size.width) + 10)*bin1Count)
                           bin1.addChild(temp)
                           bin1Count += 1
                       }
                       else if bin2Count < 4 {
                           temp.position.x = -(bin2.size.width/2) + 50
                           temp.position.x += CGFloat((Int(temp.size.width) + 10)*bin2Count)
                           bin2Count += 1
                           bin2.addChild(temp)
                       }
                       else if bin3Count < 4{
                           temp.position.x = -(bin3.size.width/2) + 50
                           temp.position.x += CGFloat((Int(temp.size.width) + 10)*bin3Count)
                           bin3Count += 1
                           bin3.addChild(temp)
                }
                currentPageStart += 1
            }
        } else {
            currentPageEnd = availableItems.count - 1
            for n in currentPageStart...currentPageEnd {
                      let temp = createItem(numItem: n)
                       if bin1Count < 4 {
                           temp.position.x = -(bin1.size.width/2) + 50
                           temp.position.x += CGFloat((Int(temp.size.width) + 10)*bin1Count)
                           bin1.addChild(temp)
                           bin1Count += 1
                       }
                       else if bin2Count < 4 {
                           temp.position.x = -(bin2.size.width/2) + 50
                           temp.position.x += CGFloat((Int(temp.size.width) + 10)*bin2Count)
                           bin2Count += 1
                           bin2.addChild(temp)
                       }
                       else if bin3Count < 4{
                           temp.position.x = -(bin3.size.width/2) + 50
                           temp.position.x += CGFloat((Int(temp.size.width) + 10)*bin3Count)
                           bin3Count += 1
                           bin3.addChild(temp)
                }
            }
        }
    }
    
    func pageClear() {
        bin1.removeAllChildren()
        bin1.removeFromParent()
        bin2.removeAllChildren()
        bin2.removeFromParent()
        bin3.removeAllChildren()
        bin3.removeFromParent()
    }
    
    func pageForward() {
        if availableItems.count > currentPageNum*12 {
            pageClear()
            currentPageNum += 1
            showPage(pageNum: currentPageNum)
        }
    }
    
    func pageBack() {
        if currentPageNum != 1 {
            pageClear()
            currentPageNum -= 1
            showPage(pageNum: currentPageNum)
        }
    }
    
    func createItem(numItem: Int) -> SKSpriteNode{
        let test = ItemNode(item: availableItems[numItem])
        return test
        }
    
    func doubleCheck() {
        // Are you sure you want to purchase item.name?
    }
    
    func setCostume(costume: String) {
        statics.setPlayerCostume(value: costume)
    }
}
