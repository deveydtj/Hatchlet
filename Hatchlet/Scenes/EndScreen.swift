//
//  Menu.swift
//  Lil Jumper
//
//  Created by Admin on 10/18/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class EndScreen: SKNode {
    let size: CGSize
    var score: Int
    var bestStreak: Int
    let menu: SKSpriteNode
    let streakSummary: ShadowLabelNode
    let finalScore: ShadowLabelNode
    let bestStreakLabel: ShadowLabelNode

    var menuTexture = SKTexture()
    
    init(size: CGSize, score: Int, bestStreak: Int = 0){
        self.size = size
        self.score = score
        self.bestStreak = bestStreak
        menu = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 150, height: 40))
        
        streakSummary = ShadowLabelNode(fontNamed: "AmaticSC-Bold", shadowOffset: CGPoint(x: 2.5, y: -1.5))
        finalScore = ShadowLabelNode(fontNamed: "AmaticSC-Bold", shadowOffset: CGPoint(x: 2.5, y: -1.5))
        bestStreakLabel = ShadowLabelNode(fontNamed: "AmaticSC-Bold", shadowOffset: CGPoint(x: 2.5, y: -1.5))
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        menuTexture = Constant.textureNamed("mainMenu")
        
        menu.name = "menu"
        menu.zPosition = 71
        menu.position = CGPoint(x: size.width / 2, y: size.height / 2 - 82)
        menu.size = CGSize(width: 77, height: 80)
        menu.texture = menuTexture
        addChild(menu)

        streakSummary.text = streakSaying(for: bestStreak)
        streakSummary.fontSize = 42
        streakSummary.position = CGPoint(x: size.width / 2, y: size.height / 2 + 112)
        streakSummary.zPosition = 72
        streakSummary.fontColor = .init(displayP3Red: 250.0/255.0, green: 209.0/255.0, blue: 92.0/255.0, alpha: 1)
        streakSummary.shadowColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(streakSummary)
        
        finalScore.text = "Your Score: " + String(score)
        finalScore.fontSize = 55
        finalScore.position = CGPoint(x: size.width / 2, y: size.height / 2 + 44)
        finalScore.zPosition = 72
        finalScore.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        finalScore.shadowColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(finalScore)

        bestStreakLabel.text = bestStreakLine()
        bestStreakLabel.fontSize = 38
        bestStreakLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 2)
        bestStreakLabel.zPosition = 72
        bestStreakLabel.fontColor = .init(displayP3Red: 244.0/255.0, green: 237.0/255.0, blue: 224.0/255.0, alpha: 1)
        bestStreakLabel.shadowColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(bestStreakLabel)
    }

    private func bestStreakLine() -> String {
        let eggWord = bestStreak == 1 ? "egg" : "eggs"
        return "Best Streak: \(bestStreak) \(eggWord)"
    }

    private func streakSaying(for streak: Int) -> String {
        switch streak {
        case 0:
            return "Ready for another crack?"
        case 1...5:
            return "Off to a start"
        case 6...14:
            return "Finding your rhythm"
        case 15...24:
            return "Eggcellent run"
        case 25...39:
            return "Hot streak"
        case 40...59:
            return "Cracking records"
        default:
            return "Legendary hatch"
        }
    }
}
