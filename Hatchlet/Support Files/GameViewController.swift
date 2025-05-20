//
//  GameViewController.swift
//  Lil Jumper
//
//  Created by Admin on 5/11/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.frame.size)
        
        let view = self.view as! SKView
        scene.scaleMode = .aspectFill
        
        view.ignoresSiblingOrder = true
        view.showsDrawCount = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsQuadCount = true
        // Present the scene
        view.presentScene(scene)
        

        }
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
