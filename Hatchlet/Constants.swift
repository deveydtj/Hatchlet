//
//  Constants.swift
//  Hatchlet
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//

import Foundation

struct Constants {
    
    var gameOver: Bool = true
    
    var gameDifficulty = UserDefaults.standard.integer(forKey: "gameDifficulty")
    
    var gameTutorialOn = UserDefaults.standard.bool(forKey: "gameTut")
    
    let playButton = "playButton"
    let crownButton = "crownButton"
    let crownBackButton = "crownBackButton"
    let settingsButton = "settingsButton"
    let settingsBackButton = "settingsBackButton"
    let shopButton = "shopButton"
    let shopBackButton = "shopBackButton"
    let menu = "menu"
    
    mutating func setGameTut(value: Bool) {
        UserDefaults.standard.set(value, forKey: "gameTut")
        gameTutorialOn = UserDefaults.standard.bool(forKey: "gameTut")
    }
    
    mutating func setGameMode(value: Int = 1) {
        UserDefaults.standard.set(value, forKey: "gameDifficulty")
        gameDifficulty = UserDefaults.standard.integer(forKey: "gameDifficulty")
    }
}


