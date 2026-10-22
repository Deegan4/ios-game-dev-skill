import SceneKit

/// Production-oriented player controller with walk animation support.
/// Call update(deltaTime:in:) from the renderer delegate.
final class PlayerController {
    let node: SCNNode
    private let visuals: CharacterVisuals?
    private(set) var velocity = SCNVector3Zero
    private var input = SCNVector3Zero
    private var grounded = false
    
    var moveSpeed: Float = 6.0
    var jumpForce: Float = 8.0
    var gravity: Float = -20.0
    var groundCheckDistance: Float = 0.6
    
    init(node: SCNNode, visuals: CharacterVisuals? = nil) {
        self.node = node
        self.visuals = visuals
        let body = SCNPhysicsBody(type: .kinematic, shape: nil)
        body.categoryBitMask = 1 << 0
        body.collisionBitMask = (1 << 3)
        body.contactTestBitMask = (1 << 1) | (1 << 4)
        node.physicsBody = body
    }
    
    func setInput(_ direction: SCNVector3) {
        input = direction
    }
    
    func jump() {
        guard grounded else { return }
        velocity.y = jumpForce
        grounded = false
    }
    
    func update(deltaTime: Float, in scene: SCNScene) {
        let horizontal = input * moveSpeed
        velocity.x = horizontal.x
        velocity.z = horizontal.z
        
        if !grounded {
            velocity.y += gravity * deltaTime
        }
        
        let displacement = velocity * deltaTime
        node.position += displacement
        
        // Face movement direction
        let flatSpeed = hypot(velocity.x, velocity.z)
        if flatSpeed > 0.1 {
            let angle = atan2(velocity.x, velocity.z)
            node.eulerAngles.y = angle
        }
        
        // Drive walk animation
        visuals?.setWalking(flatSpeed > 0.5 && grounded)
        
        grounded = checkGround(in: scene)
        if grounded && velocity.y < 0 {
            velocity.y = 0
        }
    }
    
    private func checkGround(in scene: SCNScene) -> Bool {
        let from = node.position
        let to = from + SCNVector3(0, -groundCheckDistance, 0)
        let results = scene.physicsWorld.rayTestWithSegment(from: from, to: to, options: nil)
        return !results.isEmpty
    }
}
