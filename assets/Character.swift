import SceneKit

/// Procedural 3D character with idle and walk cycles driven by SCNActions on the limbs.
/// Call setWalking(_:) from the controller when horizontal speed changes.
final class CharacterVisuals {
    let root: SCNNode
    let torso: SCNNode
    private let leftArm: SCNNode
    private let rightArm: SCNNode
    private let leftLeg: SCNNode
    private let rightLeg: SCNNode
    private var isWalking = false
    
    init() {
        root = SCNNode()
        root.name = "Player"
        
        // Torso
        torso = SCNNode(geometry: SCNBox(width: 0.5, height: 0.7, length: 0.25, chamferRadius: 0.05))
        torso.position = SCNVector3(0, 1.1, 0)
        torso.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
        root.addChildNode(torso)
        
        // Head
        let head = SCNNode(geometry: SCNSphere(radius: 0.22))
        head.position = SCNVector3(0, 0.55, 0)
        head.geometry?.firstMaterial?.diffuse.contents = UIColor.systemOrange
        torso.addChildNode(head)
        
        // Arms
        leftArm = makeLimb(radius: 0.08, height: 0.55, color: .systemBlue)
        leftArm.position = SCNVector3(-0.38, 0.1, 0)
        torso.addChildNode(leftArm)
        
        rightArm = makeLimb(radius: 0.08, height: 0.55, color: .systemBlue)
        rightArm.position = SCNVector3(0.38, 0.1, 0)
        torso.addChildNode(rightArm)
        
        // Legs
        leftLeg = makeLimb(radius: 0.09, height: 0.7, color: .darkGray)
        leftLeg.position = SCNVector3(-0.15, -0.7, 0)
        root.addChildNode(leftLeg)
        
        rightLeg = makeLimb(radius: 0.09, height: 0.7, color: .darkGray)
        rightLeg.position = SCNVector3(0.15, -0.7, 0)
        root.addChildNode(rightLeg)
        
        playIdle()
    }
    
    private func makeLimb(radius: CGFloat, height: CGFloat, color: UIColor) -> SCNNode {
        let node = SCNNode(geometry: SCNCapsule(capRadius: radius, height: height))
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
    }
    
    func setWalking(_ walking: Bool) {
        guard walking != isWalking else { return }
        isWalking = walking
        if walking {
            playWalk()
        } else {
            playIdle()
        }
    }
    
    private func playIdle() {
        removeLimbActions()
        let bob = SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 0.025, z: 0, duration: 0.7),
            SCNAction.moveBy(x: 0, y: -0.025, z: 0, duration: 0.7)
        ])
        torso.runAction(SCNAction.repeatForever(bob), forKey: "idle")
    }
    
    private func playWalk() {
        removeLimbActions()
        torso.removeAction(forKey: "idle")
        
        let swing = Float.pi / 5
        let duration: TimeInterval = 0.35
        
        func swingAction(forward: Bool) -> SCNAction {
            let angle = forward ? swing : -swing
            return SCNAction.sequence([
                SCNAction.rotateTo(x: CGFloat(angle), y: 0, z: 0, duration: duration),
                SCNAction.rotateTo(x: CGFloat(-angle), y: 0, z: 0, duration: duration)
            ])
        }
        
        leftLeg.runAction(SCNAction.repeatForever(swingAction(forward: true)), forKey: "walk")
        rightLeg.runAction(SCNAction.repeatForever(swingAction(forward: false)), forKey: "walk")
        leftArm.runAction(SCNAction.repeatForever(swingAction(forward: false)), forKey: "walk")
        rightArm.runAction(SCNAction.repeatForever(swingAction(forward: true)), forKey: "walk")
    }
    
    private func removeLimbActions() {
        leftArm.removeAction(forKey: "walk")
        rightArm.removeAction(forKey: "walk")
        leftLeg.removeAction(forKey: "walk")
        rightLeg.removeAction(forKey: "walk")
    }
}

/// Convenience that returns a fully controllable character.
func makePlayableCharacter() -> (node: SCNNode, controller: PlayerController, visuals: CharacterVisuals) {
    let visuals = CharacterVisuals()
    let controller = PlayerController(node: visuals.root, visuals: visuals)
    return (visuals.root, controller, visuals)
}
