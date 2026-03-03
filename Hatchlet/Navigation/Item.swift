//
//  Constants.swift
//  Hatchlet
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//

import SpriteKit

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

  static let list = (
    // Hard-code any new costumes you create here (this is a "master list" of costumes)
    // (make sure all of your costumes have a unique name, or the program will not work properly)
    blank: Item(name: "bob",  texture: Constant.textureNamed("bob"),  price:  0),
    gangster:  Item(name: "gangster",  texture: Constant.textureNamed("gangster"),  price:  0),
    covid:   Item(name: "covid",   texture: Constant.textureNamed("covid"),   price: 5),
    glasses:   Item(name: "glasses",   texture: Constant.textureNamed("glasses"),   price: 5),
    cow:   Item(name: "cow",   texture: Constant.textureNamed("cow"),   price: 5),
    unicorn:   Item(name: "unicorn",   texture: Constant.textureNamed("unicorn"),   price: 25),
    hotdog:   Item(name: "hotdog",   texture: Constant.textureNamed("hotdog"),   price: 100)
  )

  //static let defaultCostume = list.gray
};
