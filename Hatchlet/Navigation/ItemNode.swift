//
//  Constants.swift
//  Hatchlet
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//

import Foundation
import SpriteKit

/// The items that are for sale in our shop:
class ItemNode:SKSpriteNode {
    
    let item:Item
    
    var priceNode = SKLabelNode()
    
    private func label(text: String) -> SKLabelNode {
      let label = SKLabelNode(text: text)
      label.fontName = "AmaticSC-Bold"
        label.fontSize = 45
        label.position = CGPoint(x: 0, y: -60)
        label.zPosition = 7
      return label
    }

    init(item: Item) {
        
        self.item = item

        let size = CGSize(width: 135 / 2.25, height: 118.3 / 2.25)
        
        super.init(texture: item.texture, color: .purple, size: size)

        name = item.name   // Name is needed for sorting and detecting touches.
        priceNode = label(text: "\(item.price)")
        zPosition = 7
        setPriceText()
        addChild(priceNode)
      }
    
    func setupNodes() {
        let price = label(text: "\(item.price)")
        priceNode = price
        addChild(priceNode)
    }
    
    func setPriceText() { // Updates the color and text of price labels
        var owned = false
        for itemName in const.ownedItems {
               if item.name == itemName {
                  owned = true
            }
        }
        if owned {
            playerOwns()
        } else {
            if const.goldenEggs >=  item.price{
                playerCanAfford()
            } else {
                playerCantAfford()
            }
        }
    }
    
    func playerCanAfford() {
      priceNode.text = "\(item.price)"
      priceNode.fontColor = .green
    }

    func playerCantAfford() {
      priceNode.text = "\(item.price)"
      priceNode.fontColor = .red
    }

    func playerOwns() {
      priceNode.text = ""
      priceNode.fontColor = .white
    }

      required init?(coder aDecoder: NSCoder) { fatalError() }

      deinit { /*print("costumenode: if you don't see this then you have a retain cycle")*/ }
    };
