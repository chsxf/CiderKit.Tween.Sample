import Cocoa
import SpriteKit
import GameplayKit
import CiderKit_Tween
import Combine

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    @IBOutlet var buttonContainer: NSStackView!
    @IBOutlet var loopingTweenButton: NSButton!
    @IBOutlet var testSequenceButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonContainer.isHidden = true
        
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
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(onIntroSequenceCompleted), name: .introCompleted, object: scene)
                        NotificationCenter.default.addObserver(self, selector: #selector(onTestCompleted), name: .testCompleted, object: scene)
                    }

                    view.ignoresSiblingOrder = true

                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    @objc
    func onIntroSequenceCompleted() {
        buttonContainer.isHidden = false
        NotificationCenter.default.removeObserver(self, name: .introCompleted, object: self)
    }
    
    @IBAction func onLoopingTweenClicked(_ sender: NSButton) {
        if let gameScene = skView.scene as? GameScene {
            buttonContainer.isHidden = true
            Task {
                await gameScene.loopLabelAlpha()
            }
        }
    }
    
    @IBAction func onTestSequenceClicked(_ sender: NSButton) {
        if let gameScene = skView.scene as? GameScene {
            buttonContainer.isHidden = true
            Task {
                await gameScene.animateLabelSequence()
            }
        }
    }
    
    @objc
    func onTestCompleted() {
        buttonContainer.isHidden = false
    }
}
