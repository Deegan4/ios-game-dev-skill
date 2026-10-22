import SceneKit

/// Creates a ready-to-use SceneKit scene with camera rig, three-point lighting, physics floor, and a 3D player character.
/// Returns the scene, camera rig, and the playable character node + controller.
func makeProductionScene() -> (scene: SCNScene, cameraRig: SCNNode, character: SCNNode, controller: PlayerController) {
    let scene = SCNScene()
    scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
    
    // Camera rig
    let cameraRig = SCNNode()
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.camera?.zFar = 200
    cameraNode.camera?.fieldOfView = 60
    cameraNode.position = SCNVector3(0, 4, 10)
    cameraRig.addChildNode(cameraNode)
    scene.rootNode.addChildNode(cameraRig)
    
    // Three-point lighting
    func makeLight(type: SCNLight.LightType, position: SCNVector3, intensity: CGFloat) -> SCNNode {
        let node = SCNNode()
        node.light = SCNLight()
        node.light?.type = type
        node.light?.intensity = intensity
        node.light?.castsShadow = (type == .directional || type == .spot)
        node.position = position
        return node
    }
    
    scene.rootNode.addChildNode(makeLight(type: .directional, position: SCNVector3(5, 10, 5), intensity: 1000))
    scene.rootNode.addChildNode(makeLight(type: .omni, position: SCNVector3(-4, 6, 2), intensity: 400))
    scene.rootNode.addChildNode(makeLight(type: .omni, position: SCNVector3(0, 3, -6), intensity: 200))
    
    // Floor
    let floor = SCNNode(geometry: SCNFloor())
    floor.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
    floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    floor.physicsBody?.categoryBitMask = 1 << 3
    scene.rootNode.addChildNode(floor)
    
    // 3D Character with walk cycle
    let (character, controller, _) = makePlayableCharacter()
    character.position = SCNVector3(0, 0.1, 0)
    scene.rootNode.addChildNode(character)
    
    return (scene, cameraRig, character, controller)
}
