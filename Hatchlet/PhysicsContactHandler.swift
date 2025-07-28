//
//  PhysicsContactHandler.swift
//  Hatchlet
//
//  Created by jake on 5/17/25.
//  Copyright © 2025 Jacob DeVeydt. All rights reserved.
//

import SpriteKit

class PhysicsContactHandler {
    private weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
    }

    /// Called when two physics bodies begin contact
    func didBegin(_ contact: SKPhysicsContact) {
        guard let s = scene else { return }
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Egg hits player
        if collision == PhysicsCategory.Egg | PhysicsCategory.Player {
            if contact.bodyA.categoryBitMask == PhysicsCategory.Egg {
                if let node = contact.bodyA.node, let eggType = node.name {
                    s.gameLogic.setScore(eggType: eggType)
                    s.gameLogic.deleteEgg(egg: node)
                }
            } else {
                if let node = contact.bodyB.node, let eggType = node.name {
                    s.gameLogic.setScore(eggType: eggType)
                    s.gameLogic.deleteEgg(egg: node)
                }
            }
        }

        // Roof hits player → spawn eagle
        if collision == PhysicsCategory.Roof | PhysicsCategory.Player {
            if !s.const.gameOver && !s.eagle.isRunning() {
                s.eagle = Eagle()
                s.eagle.position = CGPoint(x: s.size.width + s.eagle.size.width,
                                           y: s.size.height / 2)
                s.addChild(s.eagle)
                s.eagle.run(speed: s.gameSpeed, viewSize: s.size)
            }
            s.emitter.addEmitterOnPlayer(fileName: "feathers",
                                         position: s.player.position)
        }

        // Ground hits player → grass puff + maybe fox
        if collision == PhysicsCategory.Ground | PhysicsCategory.Player {
            s.emitter.addEmitterOnPlayer(fileName: "grass",
                                         position: s.player.position,
                                         deleteTime: 0.4)
            if !s.const.gameOver && !s.fox.isRunning() && s.scoreNum >= 1 {
                s.gameLogic.spawnEnemy()
            }
        }

        // Enemy hits ground → grass
        if collision == PhysicsCategory.Enemy | PhysicsCategory.Ground {
            let pos = CGPoint(x: s.fox.position.x, y: s.fox.position.y - 15)
            s.emitter.addEmitterOnPlayer(fileName: "grass",
                                         position: pos,
                                         deleteTime: 0.4)
        }

        // Player hits enemy → lose life or game over
        if collision == PhysicsCategory.Player | PhysicsCategory.Enemy {
            if contact.bodyB.node?.name == "fox" {
                s.fox.stop()
            } else {
                s.eagle.stop()
            }
            s.HUD.enemyShadow.isHidden = true
            if s.HUD.removeLife() == false {
                s.gameLogic.endGame()
            }
            s.player.hurtHead()
            s.emitter.addEmitterOnPlayer(fileName: "newSpark",
                                         position: s.player.position)
        }
    }

    /// Called when two physics bodies end contact (no-op for now)
    func didEnd(_ contact: SKPhysicsContact) {
        // nothing to do here yet
    }
}
