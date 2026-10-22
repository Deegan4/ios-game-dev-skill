---
name: ios-game-dev
description: "Build and implement iOS games using SwiftUI, SceneKit, and RealityKit. Use when creating player controllers, scenes, physics, Game Center integration, procedural generation, or shipping iOS games."
type: workflow
lifecycle: active
---

# iOS Game Dev — SwiftUI + SceneKit / RealityKit

Build playable iOS games with SwiftUI hosting SceneKit or RealityKit scenes. Focus on controllers, physics, input, Game Center, and common game loops.

## When to Use

Activate for:
- SceneKit or RealityKit scene setup in a SwiftUI app
- Player character controllers (touch, gesture, physics)
- Object pooling, spawning, or procedural elements
- Game Center leaderboards, achievements, authentication
- Endless runners, simple 3D interactions, or physics-based gameplay
- TestFlight / App Store game submission notes specific to games

Do **not** use for pure 2D SpriteKit-only games, non-Apple platforms, or general SwiftUI UI (use other skills).

## Core Workflow

1. **Identify the engine**: SceneKit for classic 3D, RealityKit for modern AR/visionOS-friendly. Default to SceneKit unless user specifies RealityKit or AR.
2. **Set up the scene host**: Use `SCNView` wrapped in `UIViewRepresentable` or `RealityView` inside SwiftUI.
3. **Add physics and input**: Create player node, physics body, and gesture/touch handlers. See `references/scenekit-basics.md`.
4. **Implement game loop elements**: Spawning, scoring, state. Prefer ScriptableObject-style data where possible (enums + structs).
5. **Add Game Center** if requested: Authentication, leaderboards, achievements. See `references/gamecenter.md`.
6. **Test and package**: Note required capabilities (Game Center, ARKit if used) in Info.plist and entitlements.

Always prefer modern Swift concurrency (`async/await`, `Task`) and SwiftUI lifecycle over older patterns.

## Quick Start Patterns

### SceneKit Player Controller
Copy and adapt the starter from `assets/PlayerController.swift`. Attach to an `SCNNode` with a physics body.

### SwiftUI Host
```swift
struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = makeScene()
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        return view
    }
    func updateUIView(_ uiView: SCNView, context: Context) {}
}
```

### Game Center Auth
See the authentication flow in `references/gamecenter.md`. Call early in `App` or root view `.task`.

## Resources

- **references/scenekit-basics.md**: Node hierarchy, physics, camera follow, lighting, common gotchas.
- **references/gamecenter.md**: Auth, leaderboards, achievements, error handling.
- **references/procedural-endless.md**: Chunk streaming, difficulty curves, modular/procedural generation, object pooling, seeding for endless runners and infinite worlds.
- **assets/Character.swift**: Procedural 3D humanoid (torso, head, arms, legs) with idle animation and a `makePlayableCharacter()` helper that pairs it with the controller.
- **assets/PlayerController.swift**: Kinematic-hybrid controller with ground check, gravity, and jump.
- **assets/SceneSetup.swift**: Production scene that now includes the 3D character out of the box.

## Common Issues

| Problem | Fix |
|---------|-----|
| Scene not updating from SwiftUI state | Bind via `Coordinator` or `@Binding` into the representable; avoid capturing self strongly. |
| Physics body falls through floor | Ensure floor has `SCNPhysicsBody.static` and player has `dynamic` with appropriate collision bit masks. |
| Game Center auth fails silently | Check capability + entitlement; handle `GKLocalPlayer.local.authenticateHandler` errors. |
| High CPU on device | Disable `allowsCameraControl` in release; use `SCNView.preferredFramesPerSecond`. |

Load the relevant reference file only when the specific topic is needed. Keep this file lean.
