//
//  ScrollingManager.swift
//  Hatchlet
//
//  Created by jake on 5/17/25.
//  Copyright © 2025 Jacob DeVeydt. All rights reserved.
//

import SpriteKit

class ScrollingManager {
    private weak var scene: GameScene?
    private var lastUpdateTime: TimeInterval = 0

    init(scene: GameScene) {
        self.scene = scene
    }

    /// Call this from GameScene.update(_:)
    func update(currentTime: TimeInterval) {
        guard let s = scene else { return }

        // Compute delta time
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if deltaTime > 1 { deltaTime = 0 }

        // Don’t scroll if game over
        guard !s.const.gameOver else { return }

        // Reset and restart landscape loop
        checkAndScroll(node: s.landscapeBin, speed: s.gameSpeed)

        // Reset and restart ground loop
        checkAndScroll(node: s.scrollingGroundBin, speed: s.gameSpeed * 10)

        // If eagle is in flight, move it closer to the player
        if s.eagle.isRunning() {
            moveEagleCloser(deltaTime: deltaTime)
        }
    }

    // MARK: - Private Helpers

    private func checkAndScroll(node: SKNode, speed: Double) {
        guard let s = scene else { return }
        // Once the node has fully scrolled off-screen, reset it
        if node.position.x < -s.size.width {
            node.removeAllActions()
            node.position = .zero
            scroll(node: node, speed: speed)
        }
    }

    private func scroll(node: SKNode, speed: Double) {
        // Scroll by half the node’s width, then snap back
        let distance = node.calculateAccumulatedFrame().width / 2
        let moveLeft  = SKAction.moveBy(x: -distance, y: 0, duration: speed)
        let reset     = SKAction.run { node.position = .zero }
        let sequence  = SKAction.sequence([moveLeft, reset])
        node.run(.repeatForever(sequence), withKey: node.name! + "MoveLeft")
    }

    private func moveEagleCloser(deltaTime: TimeInterval) {
        guard let s = scene else { return }
        // Non-linear y-approach towards the player
        let deltaY = s.player.position.y - s.eagle.position.y
        if s.eagle.position.x > s.size.width / 2 {
            let adjustment = CGFloat(s.eagleSpeed) * CGFloat(deltaTime)
            s.eagle.position.y += deltaY * adjustment
        }
    }
}
