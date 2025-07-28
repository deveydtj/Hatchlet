//
//  Emitters.swift
//  Lil Jumper
//
//  Created by Admin on 10/13/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import SpriteKit

class Emitters:SKNode {
    
    let size:CGSize
    
    let Particles = SKTextureAtlas(named: "Particles")
    
    init(size: CGSize){
        self.size = size
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // Texture already preloaded in GameLogic.setup() for better performance
    }
    
    func addEmitter(position: CGPoint, texture: String = "sparkTest") {
        guard let emitter = SKEmitterNode(fileNamed: "spark") else { return }
        let textureAtlas = Particles.textureNamed(texture)
        emitter.particleTexture = textureAtlas
        emitter.zPosition = 6
        emitter.position = position
        addChild(emitter)
        
        // Use SKAction instead of DispatchQueue to avoid memory leaks
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])
        emitter.run(removeAction)
    }
    
    func addEmitterOnPlayer(fileName: String, position: CGPoint, deleteTime: Double = 2) {
        guard let emitter = SKEmitterNode(fileNamed: fileName) else { return }
        emitter.zPosition = 6
        
        
        let textureAtlas = Particles.textureNamed("feather")
        emitter.particleTexture = textureAtlas
        
        if fileName == "airParticles" {
            let textureAtlas = Particles.textureNamed("spark")
            emitter.particleTexture = textureAtlas
            emitter.name = "airParticles"
            emitter.zPosition = 4
            emitter.particlePositionRange = CGVector(dx: 0, dy: size.height / 1.5)
        }
        
        if fileName == "playerSmoke"  {
            emitter.position = CGPoint(x: position.x, y: position.y - (65 / 2))
            let textureAtlas = Particles.textureNamed("spark")
            emitter.particleTexture = textureAtlas
        }
        else if fileName == "grass" {
            emitter.position = CGPoint(x: position.x, y: position.y - (62 / 2))
            let textureAtlas = Particles.textureNamed("grassParticle")
            emitter.particleTexture = textureAtlas
            emitter.zPosition = 100
        } else {
            emitter.position = position
        }
        
        //65 is the current player height...could get player height by
        // making a new Player() or passing in player.height
        addChild(emitter)
        
        //below code creates a delay before deleting the emitter
        if deleteTime == -1 {
        } else {
            // Use SKAction instead of DispatchQueue to avoid memory leaks
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: deleteTime),
                SKAction.removeFromParent()
            ])
            emitter.run(removeAction)
        }
    }
    
    func updateSpeed() {
        guard let test = childNode(withName: "airParticles") as? SKEmitterNode else { return }
        
        print(test.particleSpeed)
        test.particleSpeed += 0.90
    }
    
    func resetSpeed() {
        guard let test = childNode(withName: "airParticles") as? SKEmitterNode else { return }
        
        test.particleSpeed = 45
    }
}
