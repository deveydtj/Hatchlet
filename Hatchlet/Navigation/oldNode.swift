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
class OldNode:SKSpriteNode {

    let item: Item
    
    private(set) var
    object = SKSpriteNode(),
    priceNode = SKLabelNode()
    
    private func label(text: String, size: CGSize) -> SKLabelNode {
      let label = SKLabelNode(text: text)
      label.fontName = "AmaticSC-Bold"
      // FIXME: deform label to fit size and offset
      return label
    }
    
    init(item: Item) {

         func setupNodes(with size: CGSize) {

          let price = label(text: "\(item.price)", size: size)
          price.position.y = frame.minY - price.frame.size.height

         // addChildrenBehind([bkg, name, price])  CREATE OWN!
          //(object, priceNode) = (bkg, name, price)
        }
        
        self.item = item

        let size = item.texture.size()
        
        super.init(texture: item.texture, color: .clear, size: size)

        name = item.name   // Name is needed for sorting and detecting touches.

        setupNodes(with: size)
      }

      private func setPriceText() { // Updates the color and text of price labels

        func playerCanAfford() {
          priceNode.text = "\(item.price)"
          priceNode.fontColor = .white
        }

        func playerCantAfford() {
          priceNode.text = "\(item.price)"
          priceNode.fontColor = .red
        }

        func playerOwns() {
          priceNode.text = ""
          priceNode.fontColor = .white
        }

//        if player.hasCostume(self.costume)         { playerOwns()       }
//        else if player.coins < self.costume.price  { playerCantAfford() }
//        else if player.coins >= self.costume.price { playerCanAfford()  }
//        else                                       { fatalError()       }
     }

      required init?(coder aDecoder: NSCoder) { fatalError() }

      deinit { print("costumenode: if you don't see this then you have a retain cycle") }
    };
