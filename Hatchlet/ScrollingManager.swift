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
    private var smoothedEagleTargetY: CGFloat?
    private var smoothedEagleYStep: CGFloat?

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
        } else {
            smoothedEagleTargetY = nil
            smoothedEagleYStep = nil
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

        let tuning = s.eagleTuning
        let eaglePos = s.eagle.position
        let playerPos = s.player.position

        // Keep eagle trajectory stable after it crosses mid-screen.
        if eaglePos.x <= s.size.width * 0.5 {
            smoothedEagleTargetY = eaglePos.y
            smoothedEagleYStep = 0
            return
        }

        let minY = s.size.height * tuning.minYFactor
        let maxY = s.size.height * tuning.maxYFactor
        let rawLeadY = playerPos.y + (s.player.physicsBody?.velocity.dy ?? 0) * tuning.leadFactor
        let clampedLeadY = min(max(rawLeadY, minY), maxY)

        // Smooth the target so quick player velocity changes do not create jagged vertical motion.
        let previousTargetY = smoothedEagleTargetY ?? clampedLeadY
        let targetBlend = min(CGFloat(deltaTime) * 5.0, 1)
        let filteredTargetY = previousTargetY + (clampedLeadY - previousTargetY) * targetBlend
        smoothedEagleTargetY = filteredTargetY
        let deltaY = filteredTargetY - eaglePos.y

        // Increase pursuit speed as eagle closes horizontal distance to the player.
        let horizontalGap = max(eaglePos.x - playerPos.x, 0)
        let proximity = 1 - min(horizontalGap / s.size.width, 1)
        let chaseSpeed = CGFloat(s.eagleSpeed) * tuning.baseVerticalSpeedFactor * (1 + proximity * tuning.proximityBoost)
        let maxStep = max(chaseSpeed * CGFloat(deltaTime), 0.01)

        // Saturate the chase step smoothly instead of a hard clamp to reduce visible snapping.
        let rawYStep = deltaY / (1 + (abs(deltaY) / maxStep))
        let previousYStep = smoothedEagleYStep ?? rawYStep
        let stepBlend = min(CGFloat(deltaTime) * 7.0, 1)
        let yStep = previousYStep + (rawYStep - previousYStep) * stepBlend
        smoothedEagleYStep = yStep
        s.eagle.position.y += yStep
        if abs(filteredTargetY - s.eagle.position.y) < 0.25 {
            s.eagle.position.y = filteredTargetY
        }

        s.eagle.position.y = min(max(s.eagle.position.y, minY), maxY)
    }
}
