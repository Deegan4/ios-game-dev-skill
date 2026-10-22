# Changelog

## 2026-10-22
- Initial skill creation for iOS game development with SwiftUI + SceneKit
- Added references for SceneKit basics, Game Center, and SwiftUI integration
- Added starter assets: PlayerController.swift and SceneSetup.swift
- Populated real evals and triggers
- Massively expanded all three reference files into production-grade, advanced guides (camera rigs, physics systems, shaders, Game Center resilience, advanced SwiftUI bridging, RealityKit notes)
- Upgraded assets to production quality (kinematic-hybrid PlayerController with ground check, three-point lit production scene)
- Added references/procedural-endless.md for chunk streaming, difficulty curves, and infinite runners
- Added assets/Character.swift — full procedural 3D humanoid character with idle animation
- Updated SceneSetup.swift to spawn the 3D character automatically and return the controller
- Added walk cycle: limbs swing via SCNActions, controller drives setWalking based on horizontal speed and grounds the character facing the movement direction
