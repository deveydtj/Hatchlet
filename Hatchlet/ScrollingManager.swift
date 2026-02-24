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
    private var scrollDistances: [String: CGFloat] = [:]

    init(scene: GameScene) {
        self.scene = scene
        cacheScrollDistances()
    }

    /// Call this from GameScene.update(_:)
    func update(currentTime: TimeInterval) {
        guard let s = scene else { return }

        // Compute delta time
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if deltaTime > 1 { deltaTime = 0 }

        // Only scroll during active gameplay (no game-over/menu/pause states).
        guard !s.const.gameOver, !s.newPaused, s.menu.parent == nil else { return }

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
        guard let nodeName = node.name else { return }
        let actionKey = nodeName + "MoveLeft"

        // Ensure scrolling is running when gameplay is active.
        if node.action(forKey: actionKey) == nil {
            scroll(node: node, speed: speed)
        }
    }

    private func scroll(node: SKNode, speed: Double) {
        guard let nodeName = node.name else { return }
        // Scroll by half the node's width, then snap back.
        let distance = cachedDistance(for: node)
        let moveLeft  = SKAction.moveBy(x: -distance, y: 0, duration: speed)
        let reset     = SKAction.run { node.position = .zero }
        let sequence  = SKAction.sequence([moveLeft, reset])
        node.run(.repeatForever(sequence), withKey: nodeName + "MoveLeft")
    }

    private func cacheScrollDistances() {
        guard let s = scene else { return }
        scrollDistances[s.landscapeBin.name ?? "landscapeBin"] = s.landscapeBin.calculateAccumulatedFrame().width / 2
        scrollDistances[s.scrollingGroundBin.name ?? "scrollingGroundBin"] = s.scrollingGroundBin.calculateAccumulatedFrame().width / 2
    }

    private func cachedDistance(for node: SKNode) -> CGFloat {
        let key = node.name ?? ""
        if let distance = scrollDistances[key], distance > 0 {
            return distance
        }
        let fallback = node.calculateAccumulatedFrame().width / 2
        scrollDistances[key] = fallback
        return fallback
    }

    private func moveEagleCloser(deltaTime: TimeInterval) {
        guard let s = scene else { return }
        
        // Cache positions to avoid multiple property access
        let eaglePos = s.eagle.position
        let playerY = s.player.position.y
        
        // Non-linear y-approach towards the player
        let deltaY = playerY - eaglePos.y
        if eaglePos.x > s.size.width / 2 {
            let adjustment = CGFloat(s.eagleSpeed * deltaTime)
            s.eagle.position.y += deltaY * adjustment
        }
    }
}
