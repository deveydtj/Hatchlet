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
    
    //BUTTONS
    let playButton = "playButton"
    let crownButton = "crownButton"
    let crownBackButton = "crownBackButton"
    let settingsButton = "settingsButton"
    let settingsBackButton = "settingsBackButton"
    let shopButton = "shopButton"
    let shopBackButton = "shopBackButton"
    let menu = "menu"
    
    //PLAYER
    var playerCostume = UserDefaults.standard.string(forKey: "playerCostume")
    var playerAcc = UserDefaults.standard.string(forKey: "playerAcc")
    
    mutating func setGameTut(value: Bool) {
        UserDefaults.standard.set(value, forKey: "gameTut")
        gameTutorialOn = UserDefaults.standard.bool(forKey: "gameTut")
    }
    
    mutating func setGameMode(value: Int = 1) {
        UserDefaults.standard.set(value, forKey: "gameDifficulty")
        gameDifficulty = UserDefaults.standard.integer(forKey: "gameDifficulty")
    }
    
    mutating func setPlayerCostume(value: String = "") {
        UserDefaults.standard.set(value, forKey: "playerCostume")
        playerCostume = UserDefaults.standard.string(forKey: "playerCostume")
    }
    
    mutating func setPlayerAcc(value: String = "") {
        UserDefaults.standard.set(value, forKey: "playerAcc")
        playerAcc = UserDefaults.standard.string(forKey: "playerAcc")
    }
}


