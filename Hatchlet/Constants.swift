//
//  Constants.swift
//  Hatchlet
//
//  Created by Admin on 2/23/20.
//  Copyright © 2020 Jacob DeVeydt. All rights reserved.
//

import Foundation

class Constants {
    static let shared = Constants()
    
    // Cached high score to avoid frequent UserDefaults access
    private var _highScore: Int = 0
    var highScore: Int {
        get { return _highScore }
        set {
            _highScore = newValue
            UserDefaults.standard.set(newValue, forKey: "highScore")
        }
    }
    
    private init() {
        // Load saved items or start empty
        if let saved = UserDefaults.standard.stringArray(forKey: "OwnedItems") {
            ownedItems = saved
        } else {
            ownedItems = []
        }
        // Ensure default "bob" skin is present
        if !ownedItems.contains("bob") {
            ownedItems.insert("bob", at: 0)
            UserDefaults.standard.set(ownedItems, forKey: "OwnedItems")
        }
        
        // Cache the high score on initialization
        _highScore = UserDefaults.standard.integer(forKey: "highScore")
    }
    
    var gameOver: Bool = true
    var checked: Bool = false
    
    // MARK: – Item name lookups
        /// Which names are full-body costumes
        let costumeItems: [String]    = ["hotdog", "unicorn", "cow"]
        /// Which names are head/face accessories
        let accessoryItems: [String]  = ["glasses", "covid", "gangster"]

    
    var gameDifficulty = UserDefaults.standard.integer(forKey: "gameDifficulty")
    
    var gameTutorialOn = UserDefaults.standard.bool(forKey: "gameTut")
    
    var goldenEggs = UserDefaults.standard.integer(forKey: "goldenEggs")
    
    //BUTTONS
    var touchableButtons = ["playButton", "crownButton", "crownBackButton", "settingsButton", "settingsBackButton", "shopButton", "shopBackButton", "menu", "pause", "playButton"]
    
    //PLAYER
    var playerCostume = UserDefaults.standard.string(forKey: "playerCostume")
    var playerAcc = UserDefaults.standard.string(forKey: "playerAcc")
    
    //var ownedItems: [Item] = [Item.list.blank]
    
    var ownedItems: [String]
    
    func setOwnedItems(value: String) {
        ownedItems.append(value)
        UserDefaults.standard.set(ownedItems, forKey: "OwnedItems")
    }
    
    func setGameTut(value: Bool) {
        UserDefaults.standard.set(value, forKey: "gameTut")
        gameTutorialOn = UserDefaults.standard.bool(forKey: "gameTut")
    }
    
    func setGameMode(value: Int = 1) {
        UserDefaults.standard.set(value, forKey: "gameDifficulty")
        gameDifficulty = UserDefaults.standard.integer(forKey: "gameDifficulty")
    }
    
    func setPlayerCostume(value: String = "") {
        UserDefaults.standard.set(value, forKey: "playerCostume")
        playerCostume = UserDefaults.standard.string(forKey: "playerCostume")
    }
    
    func setPlayerAcc(value: String = "") {
        UserDefaults.standard.set(value, forKey: "playerAcc")
        playerAcc = UserDefaults.standard.string(forKey: "playerAcc")
    }

    func setGoldenEggs(value: Int) {
        UserDefaults.standard.set(value, forKey: "goldenEggs")
        goldenEggs = value
    }
}

