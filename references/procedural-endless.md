# Procedural Generation & Endless Runners

Advanced patterns for infinite or highly variable content. Load this for runners, roguelikes, dungeon crawlers, or any system that must generate playable space on the fly.

## Core Loop Architecture

Separate three systems:

1. **Generator** — produces the next chunk of content (geometry, obstacles, pickups, enemy spawns).
2. **Streamer** — decides when to spawn the next chunk and when to despawn old ones.
3. **Player Progress Tracker** — converts player position into a scalar "distance" or "room index" that drives the generator.

```swift
protocol ChunkGenerator {
    func generate(at index: Int, difficulty: Float) -> SCNNode
}

final class EndlessStreamer {
    private let generator: ChunkGenerator
    private var activeChunks: [Int: SCNNode] = [:]
    private let chunkLength: Float = 20
    private let keepBehind: Int = 1
    private let keepAhead: Int = 3
    
    func update(playerZ: Float, parent: SCNNode) {
        let currentIndex = Int(playerZ / chunkLength)
        let needed = (currentIndex - keepBehind)...(currentIndex + keepAhead)
        
        // Spawn missing
        for i in needed where activeChunks[i] == nil {
            let chunk = generator.generate(at: i, difficulty: Float(i) * 0.1)
            chunk.position.z = Float(i) * chunkLength
            parent.addChildNode(chunk)
            activeChunks[i] = chunk
        }
        
        // Despawn old
        for (i, node) in activeChunks where !needed.contains(i) {
            node.removeFromParentNode()
            activeChunks.removeValue(forKey: i)
        }
    }
}
```

## Difficulty Curves That Don't Feel Cheap

- Linear early, then exponential or logistic after a "tutorial" distance.
- Separate axes: speed, obstacle density, enemy aggression, pickup scarcity.
- Use a seeded RNG (`GKMersenneTwisterRandomSource` or a simple xorshift) so the same run is reproducible for debugging and daily challenges.

```swift
struct Difficulty {
    let distance: Float
    var speedMultiplier: Float { 1.0 + distance * 0.002 }
    var obstacleChance: Float { min(0.15 + distance * 0.0008, 0.65) }
    var gapWidth: Float { max(4.0 - distance * 0.001, 1.2) }
}
```

## Chunk Design Patterns

### Modular Segments
Build a library of 8–15 hand-authored segment templates (straight, left turn, jump gap, enemy cluster, pickup alley). The generator picks and stitches them with simple rules (no two jumps in a row, guarantee a safe path, etc.).

### Fully Procedural
- Floor: extruded spline or repeating tile with random height variation.
- Obstacles: Poisson-disk or grid-based placement with minimum spacing.
- Validation pass: after generation, run a cheap pathfinder or "can the player survive this?" simulation; regenerate if it fails.

### Object Pooling
Never `SCNNode()` + add geometry every frame. Pre-warm pools for common obstacles, coins, and particles. The streamer pulls from the pool and returns nodes on despawn.

## Performance Rules for Infinite Worlds

- Hard cap on active nodes (e.g., 150–200). Despawn aggressively.
- Share materials and geometries across all chunks.
- Disable physics on chunks more than N units behind the player.
- Use `SCNNode.flatten()` on static chunk geometry after generation.
- Profile with the SceneKit debug overlay; watch draw call count and physics body count.

## Seeding & Daily Challenges

```swift
func dailySeed() -> UInt64 {
    let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
    return UInt64(day)
}
```
Feed the seed into your RNG at the start of a run. Same seed = same layout. Perfect for leaderboards and "daily" modes.

## Integration with the Rest of the Skill

- Drive the streamer from the `GameCoordinator.renderer(_:updateAtTime:)` in `swiftui-integration.md`.
- Use the collision categories from `scenekit-basics.md` so generated obstacles interact correctly with the player.
- Report distance or score to Game Center via the patterns in `gamecenter.md`.

## Failure Modes

| Problem | Fix |
|---------|-----|
| Hitch on chunk spawn | Pre-generate next chunk on a background queue; only attach on main. |
| Impossible gaps | Add a validation pass or bias the generator toward safe segments. |
| Memory growth | Confirm despawn is actually removing nodes and returning pooled objects. |
| Physics explosions | Disable physics on distant chunks; use kinematic or static bodies for scenery. |

Load this file for any endless runner, procedural level, roguelike room, or infinite world request. It assumes you already have the SceneKit and SwiftUI foundations from the other references.
