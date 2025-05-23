//
//  Common.swift
//  Hatchlet
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//

import Foundation
import SpriteKit

private func makeTestTexture() -> (SKTexture, SKTexture, SKTexture, SKTexture) {

  func texit(_ sprite: SKSpriteNode) -> SKTexture { return SKView().texture(from: sprite)! }
  let size = CGSize(width: 50, height: 50)

  return (
    texit(SKSpriteNode(color: .gray,  size: size)),
    texit(SKSpriteNode(color: .red,   size: size)),
    texit(SKSpriteNode(color: .blue,  size: size)),
    texit(SKSpriteNode(color: .green, size: size))
  )
}

/// The items that are for sale in our shop:
struct Item {

  static var allItems: [Item] = []

  let name:    String
  let texture: SKTexture
  let price:   Int

  init(name: String, texture: SKTexture, price: Int) { self.name = name; self.texture = texture; self.price = price
    // This init simply adds all costumes to a master list for easy sorting later on.
    Item.allItems.append(self)
  }

  private static let (tex1, tex2, tex3, tex4) = makeTestTexture()  // Just a test needed to be deleted when you have actual assets.

  static let list = (
    // Hard-code any new costumes you create here (this is a "master list" of costumes)
    // (make sure all of your costumes have a unique name, or the program will not work properly)
    blank: Item(name: "bob",  texture: SKTexture(imageNamed: "bob"),  price:  0),
    gangster:  Item(name: "gangster",  texture: SKTexture(imageNamed: "gangster"),  price:  0),
    covid:   Item(name: "covid",   texture: SKTexture(imageNamed: "covid"),   price: 5),
    glasses:   Item(name: "glasses",   texture: SKTexture(imageNamed: "glasses"),   price: 5),
    cow:   Item(name: "cow",   texture: SKTexture(imageNamed: "cow"),   price: 5),
    unicorn:   Item(name: "unicorn",   texture: SKTexture(imageNamed: "unicorn"),   price: 25),
    hotdog:   Item(name: "hotdog",   texture: SKTexture(imageNamed: "hotdog"),   price: 100)
  )

  //static let defaultCostume = list.gray
};

