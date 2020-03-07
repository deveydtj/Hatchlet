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
        Particles.preload {}
    }
    
    func addEmitter(position: CGPoint, texture: String = "sparkTest") {
        let emitter = SKEmitterNode(fileNamed: "spark")!
        let textureAtlas = Particles.textureNamed(texture)
        emitter.particleTexture = textureAtlas
        emitter.zPosition = 6
        emitter.position = position
        addChild(emitter)
        
        //below code creates a delay before deleting the emitter
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitter.removeFromParent()
        }
    }
    
    func addEmitterOnPlayer(fileName: String, position: CGPoint, deleteTime: Double = 2) {
        let emitter = SKEmitterNode(fileNamed: fileName)!
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
            DispatchQueue.main.asyncAfter(deadline: .now() + deleteTime) {
                emitter.removeFromParent()
            }
        }
    }
    
    func updateSpeed() {
        let test: SKEmitterNode = childNode(withName: "airParticles") as! SKEmitterNode
        
        print(test.particleSpeed)
        test.particleSpeed += 0.90
    }
    
    func resetSpeed() {
        let test: SKEmitterNode = childNode(withName: "airParticles") as! SKEmitterNode
        
        test.particleSpeed = 45
    }
}
