//
//  ViewController.swift
//  CiderKit.Tween.Sample
//
//  Created by Christophe SAUVEUR on 02/08/2025.
//

import Cocoa
import SpriteKit
import GameplayKit
import CiderKit_Tween

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            if let view = self.skView {
                await TweenManager.shared.startFrom(view: view)

                await MainActor.run {
                    // Load the SKScene from 'GameScene.sks'
                    if let scene = SKScene(fileNamed: "GameScene") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill

                        // Present the scene
                        view.presentScene(scene)
                    }

                    view.ignoresSiblingOrder = true

                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
}

