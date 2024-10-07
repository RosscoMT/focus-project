/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    An `SKScene` used to represent and manage the home and end scenes of the game.
*/

import SpriteKit

class LoadGameScene: BaseScene {
    
    
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
