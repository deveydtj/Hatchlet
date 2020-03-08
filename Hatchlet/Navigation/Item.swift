//
//  Constants.swift
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
    gray:  Item(name: "Gray Shirt",  texture: tex1 /*SKTexture(imageNamed: "grayshirt")*/,  price:  0),
    red:   Item(name: "Red Shirt",   texture: tex2 /*SKTexture(imageNamed: "redshirt")*/,   price: 5),
    blue:  Item(name: "Blue Shirt",  texture: tex3 /*SKTexture(imageNamed: "blueshirt")*/,  price: 25),
    green: Item(name: "Green Shirt", texture: tex4 /*SKTexture(imageNamed: "greenshirt")*/, price: 50)
  )

  static let defaultCostume = list.gray
};

