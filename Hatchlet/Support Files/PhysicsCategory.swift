//
//  PhysicsCategory.swift
//  Lil Jumper
//
//  Created by Admin on 10/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

struct PhysicsCategory {
    static let None:UInt32 = 0                  //0000000
    static let Player:UInt32 = 0b1              //0000001
    static let Ground:UInt32 = 0b10             //0000010
    static let Egg:UInt32 = 0b100               //0000100
    static let Roof:UInt32 = 0b1000             //0001000
    static let eggDelete:UInt32 = 0b10000       //0010000
    static let Enemy:UInt32 = 0b100000          //0100000
}
