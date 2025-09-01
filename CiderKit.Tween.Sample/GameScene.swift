import SpriteKit
import GameplayKit
import Combine
import CiderKit_Tween

extension Notification.Name {
    static let introCompleted = Self.init("introCompleted")
    static let testCompleted = Self.init("testCompleted")
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            Task {
                await fadeInLabel()
            }
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }

    func fadeInLabel() async {
        guard let label else { return }

        let sequence = await Sequence()
        
        let alphaTween = await label.fade(.fromTo(0, 1), duration: 5)
        try! await sequence.append(tween: alphaTween)
        
        let colorTween = await label.tweenFontColor(.fromTo(SKColor.blue, SKColor.white), duration: 5)
        try! await sequence.insert(at: 0, tween: colorTween)
        
        let startTask = Task {
            for await _ in await sequence.onStart {
                print("Sequence started")
            }
        }

        let completionTask = Task {
            for await _ in await sequence.onCompletion {
                print("Sequence ended")
                NotificationCenter.default.post(name: .introCompleted, object: self)
            }
        }

        let _ = await (startTask.value, completionTask.value)
    }

    private func createUpdateTask(tween: Tween<CGPoint>) {
        Task {
            for await p in tween.onUpdate {
                await MainActor.run {
                    label?.position = p
                }
            }
        }
    }
    
    func loopLabelAlpha() async {
        guard let label else { return }

        let tween = await label.fade(.to(0.25), duration: 0.5, loopingType: .pingPong(loopCount: 6))
        Task {
            for await _ in tween.onCompletion {
                NotificationCenter.default.post(name: .testCompleted, object: self)
            }
        }
    }
    
    func animateLabelSequence() async {
        guard let label else { return }
        
        let sequence = await Sequence()
        
        let firstTween = await label.move(.to(CGPoint(x: 0, y: 100)), duration: 1, easing: .inOutCubic)
        try! await sequence.append(tween: firstTween)
        
        let secondTween = await label.move(.by(CGPoint(x: 0, y: -200)), duration: 2, easing: .inOutCubic, loopingType: .pingPong(loopCount: 3))
        try! await sequence.append(tween: secondTween)
        
        let thirdTween = await label.move(.to(CGPoint()), duration: 1, easing: .inOutCubic)
        try! await sequence.append(tween: thirdTween)
        
        Task {
            for await _ in await sequence.onCompletion {
                NotificationCenter.default.post(name: .testCompleted, object: self)
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
