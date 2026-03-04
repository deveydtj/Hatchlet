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
    let streakSummary: SKLabelNode
    let streakSummaryShadow: SKLabelNode
    let finalScore: SKLabelNode
    let finalScoreShadow: SKLabelNode
    let bestStreakLabel: SKLabelNode
    let bestStreakShadow: SKLabelNode

    var menuTexture = SKTexture()
    
    init(size: CGSize, score: Int, bestStreak: Int = 0){
        self.size = size
        self.score = score
        self.bestStreak = bestStreak
        menu = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: 150, height: 40))
        
        streakSummary = SKLabelNode(fontNamed: "AmaticSC-Bold")
        streakSummaryShadow = SKLabelNode(fontNamed: streakSummary.fontName)
        finalScore = SKLabelNode(fontNamed: "AmaticSC-Bold")
        finalScoreShadow = SKLabelNode(fontNamed: finalScore.fontName)
        bestStreakLabel = SKLabelNode(fontNamed: "AmaticSC-Bold")
        bestStreakShadow = SKLabelNode(fontNamed: bestStreakLabel.fontName)
        
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
        addChild(streakSummary)

        streakSummaryShadow.text = streakSummary.text
        streakSummaryShadow.fontSize = streakSummary.fontSize
        streakSummaryShadow.position = CGPoint(x: streakSummary.position.x + 2.5, y: streakSummary.position.y - 1.5)
        streakSummaryShadow.zPosition = 71
        streakSummaryShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(streakSummaryShadow)
        
        finalScore.text = "Your Score: " + String(score)
        finalScore.fontSize = 55
        finalScore.position = CGPoint(x: size.width / 2, y: size.height / 2 + 44)
        finalScore.zPosition = 72
        finalScore.fontColor = .init(displayP3Red: 214.0/255.0, green: 142.0/255.0, blue: 79.0/255.0, alpha: 1)
        addChild(finalScore)
        
        finalScoreShadow.text = "Your Score: " + String(score)
        finalScoreShadow.fontSize =  finalScore.fontSize
        finalScoreShadow.position = CGPoint(x:  finalScore.position.x + 2.5, y:  finalScore.position.y - 1.5)
        finalScoreShadow.zPosition = 71
        finalScoreShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(finalScoreShadow)

        bestStreakLabel.text = bestStreakLine()
        bestStreakLabel.fontSize = 38
        bestStreakLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 2)
        bestStreakLabel.zPosition = 72
        bestStreakLabel.fontColor = .init(displayP3Red: 244.0/255.0, green: 237.0/255.0, blue: 224.0/255.0, alpha: 1)
        addChild(bestStreakLabel)

        bestStreakShadow.text = bestStreakLabel.text
        bestStreakShadow.fontSize = bestStreakLabel.fontSize
        bestStreakShadow.position = CGPoint(x: bestStreakLabel.position.x + 2.5, y: bestStreakLabel.position.y - 1.5)
        bestStreakShadow.zPosition = 71
        bestStreakShadow.fontColor = .init(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.75)
        addChild(bestStreakShadow)
        
    }

    private func bestStreakLine() -> String {
        let eggWord = bestStreak == 1 ? "egg" : "eggs"
        return "Best Streak: \(bestStreak) \(eggWord)"
    }

    private func streakSaying(for streak: Int) -> String {
        switch streak {
        case 0:
            return "Ready for another crack?"
        case 1:
            return "Off to a start"
        case 2...4:
            return "Finding your rhythm"
        case 5...7:
            return "Eggcellent run"
        case 8...11:
            return "Hot streak"
        case 12...15:
            return "Cracking records"
        default:
            return "Legendary hatch"
        }
    }
}
