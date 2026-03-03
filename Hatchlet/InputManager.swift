//
//  InputManager.swift
//  Hatchlet
//
//  Created by jake on 5/17/25.
//  Copyright © 2025 Jacob DeVeydt. All rights reserved.
//

import SpriteKit

/// Handles all touch input routing and button interaction logic.
class InputManager {
    private weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
    }
    
    private func currentInteractionRoot(in scene: GameScene) -> SKNode {
        if scene.pauseScreen.parent != nil { return scene.pauseScreen }
        if scene.shop.parent != nil { return scene.shop }
        if scene.settings.parent != nil { return scene.settings }
        if scene.crown.parent != nil { return scene.crown }
        if scene.endScreen.parent != nil { return scene.endScreen }
        if scene.menu.parent != nil { return scene.menu }
        return scene
    }
    
    private func touchedNode(for touch: UITouch, in scene: GameScene) -> SKNode {
        if scene.menu.parent != nil {
            let location = touch.location(in: scene.menu)
            let buttons = [
                scene.menu.playButton,
                scene.menu.shopButton,
                scene.menu.settingsButton,
                scene.menu.crownButton
            ]
            return buttons.first(where: { $0.frame.contains(location) }) ?? scene.menu
        }
        
        let interactionRoot = currentInteractionRoot(in: scene)
        let location = touch.location(in: interactionRoot)
        return interactionRoot.atPoint(location)
    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = scene else { return }

        // Update touch location
        guard let touch = touches.first else { return }
        scene.location = touch.location(in: scene)
        let touchedNode = touchedNode(for: touch, in: scene)
        let isGameplayActive = !scene.const.gameOver && !scene.newPaused && scene.menu.parent == nil
        let isMainMenuActive = scene.menu.parent != nil
        let isEndScreenActive = scene.endScreen.parent != nil

        if isGameplayActive {
            scene.touched = true
            // Regular flap
            scene.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 145))
            scene.emitter.addEmitterOnPlayer(
                fileName: "playerSmoke",
                position: scene.player.position,
                deleteTime: 1
            )
            // Pause button
            if touchedNode.name == "pause" {
                scene.gameLogic.showPauseScreen()
            }
        } else {
            let allowsPlayerInteraction = isMainMenuActive || isEndScreenActive
            scene.touched = allowsPlayerInteraction
            if allowsPlayerInteraction {
                scene.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            }
            // Menu / overlay state: only animate actual button presses.
            for nodeName in scene.const.touchableButtons {
                if nodeName == touchedNode.name {
                    scene.prevTouchedNode = touchedNode
                    scene.isTouching = true
                    touchedNode.run(.scale(to: 0.80, duration: 0.15))
                }
            }
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = scene else { return }
        let isGameplayActive = !scene.const.gameOver && !scene.newPaused && scene.menu.parent == nil
        let isMainMenuActive = scene.menu.parent != nil
        let isEndScreenActive = scene.endScreen.parent != nil
        if !isGameplayActive, !isMainMenuActive, !isEndScreenActive, !scene.isTouching {
            return
        }
        
        // Track drag-over button highlighting
        guard let touch = touches.first else { return }
        scene.location = touch.location(in: scene)
        let touchedNode = touchedNode(for: touch, in: scene)
        
        var touchingNode = ""
        for nodeName in scene.const.touchableButtons {
            if nodeName == touchedNode.name {
                touchingNode = nodeName
                scene.prevTouchedNode = touchedNode
            }
        }

        if touchingNode != "" && !scene.isTouching {
            touchedNode.run(.scale(to: 0.80, duration: 0.2))
            scene.isTouching = true
        } else if touchingNode == "" && scene.prevTouchedNode.name != "" {
            scene.prevTouchedNode.run(.scale(to: 1, duration: 0.2))
            scene.prevTouchedNode = SKNode()
            scene.isTouching = false
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = scene else { return }
        scene.touched = false
        scene.const.checked = false
        scene.isTouching = false

        guard let touch = touches.first else { return }
        scene.location = touch.location(in: scene)
        let touchedNode = touchedNode(for: touch, in: scene)
        let nodeName = touchedNode.name ?? ""

        // Always allow menu play button to start gameplay.
        if nodeName == "playButton", scene.menu.parent != nil {
            scene.gameLogic.runGame()
            return
        }

        // Resume from pause
        if touchedNode.name == "playButton" {
            scene.newPaused = false
            scene.emitter.setAirParticlesActive(true)
            scene.pauseScreen.removeAllActions()
            scene.pauseScreen.removeFromParent()
            if let physicsBody = scene.player.physicsBody, !physicsBody.isDynamic {
                physicsBody.isDynamic = true
                physicsBody.velocity = scene.playerVelocity
            }
        }

        // Game-over menu interactions
        if scene.const.gameOver {
            if nodeName == "bob" && scene.shop.parent != nil {
                scene.const.setPlayerCostume(value: "")
                scene.const.setPlayerAcc(value: "")
                scene.player.updateCostume()
            }

            switch touchedNode {
            case is GameScene:
                return

            case let item as ItemNode:
                let itemName = item.name ?? ""
                let price = Int(item.priceNode.text ?? "") ?? 0
                let isAccessory = scene.const.accessoryItems.contains(itemName)
                let ownsItem = scene.const.ownedItems.contains(itemName)

                if ownsItem || scene.const.goldenEggs >= price {
                    if !ownsItem {
                        // Subtract the cost
                        let oldCount = scene.const.goldenEggs
                        let newCount = oldCount - price
                        scene.const.setGoldenEggs(value: newCount)
                        
                        // Animate the shop’s golden-egg counter
                        scene.shop.animateText(from: oldCount, to: newCount)

                        // Mark item as owned
                        scene.const.setOwnedItems(value: itemName)
                        item.setPriceText()
                    }
                    if isAccessory {
                        scene.const.setPlayerAcc(value: itemName)
                    } else {
                        scene.const.setPlayerCostume(value: itemName)
                    }
                    scene.shop.setCostume(costume: itemName, owned: true)
                    scene.player.updateCostume()
                }

            case is SKSpriteNode:
                if scene.const.touchableButtons.contains(nodeName) {
                    touchedNode.run(.scale(to: 1, duration: 0.2))
                }

            default:
                break
            }

            switch nodeName {
            case "gameDiff": scene.settings.switchGameDiff()
            case "eggSwitchTutorial": scene.settings.switchButton()
            case "playButton": scene.gameLogic.runGame()
            case "leftButton": scene.shop.pageBack()
            case "rightButton": scene.shop.pageForward()
            case "crownButton": scene.gameLogic.showCrown()
            case "crownBackButton":
                scene.crown.delete()
                scene.gameLogic.presentInitialMenu()
            case "settingsButton": scene.gameLogic.showSettings()
            case "settingsBackButton":
                scene.settings.delete()
                scene.gameLogic.presentInitialMenu()
            case "shopButton": scene.gameLogic.showShop()
            case "shopBackButton":
                scene.shop.delete()
                scene.gameLogic.presentInitialMenu()
            case "menu": scene.gameLogic.showMenu()
            default: break
            }
        }
    }
}
