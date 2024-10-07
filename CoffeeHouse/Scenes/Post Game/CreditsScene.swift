/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    `LevelScene` is an `SKScene` representing a playable level in the game. `WorldLayer` is an enumeration that represents the different z-indexed layers of a `LevelScene`.
*/

import GameplayKit
import Engine

class CreditsScene: BaseScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // Returns the background node from the scene.
    override var backgroundNode: SKSpriteNode? {
        return childNode(name: GameNodes.backgroundNode) as? SKSpriteNode
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Scene Life Cycle
    // -----------------------------------------------------------------
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Enable focus based navigation.
        focusChangesEnabled = true
        
        // Setup notifications
        centerCameraOnPoint(point: backgroundNode!.position)
    }
}
