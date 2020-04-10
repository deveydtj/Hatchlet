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

    init(item: Item) {
        
        self.item = item

        let size = CGSize(width: 135 / 2.25, height: 118.3 / 2.25)
        
        super.init(texture: item.texture, color: .purple, size: size)

        name = item.name   // Name is needed for sorting and detecting touches.
        zPosition = 7
      }

//      private func setPriceText() { // Updates the color and text of price labels
//
//        func playerCanAfford() {
//          priceNode.text = "\(item.price)"
//          priceNode.fontColor = .white
//        }
//
//        func playerCantAfford() {
//          priceNode.text = "\(item.price)"
//          priceNode.fontColor = .red
//        }
//
//        func playerOwns() {
//          priceNode.text = ""
//          priceNode.fontColor = .white
//        }
//
////        if player.hasCostume(self.costume)         { playerOwns()       }
////        else if player.coins < self.costume.price  { playerCantAfford() }
////        else if player.coins >= self.costume.price { playerCanAfford()  }
////        else                                       { fatalError()       }
//     }

      required init?(coder aDecoder: NSCoder) { fatalError() }

      deinit { /*print("costumenode: if you don't see this then you have a retain cycle")*/ }
    };
