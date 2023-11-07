//
//  GameViewController.swift
//  lolrus
//
//  Created by Alyx on 5/30/23.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Create and configure the scene
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene
        skView.presentScene(scene)
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
