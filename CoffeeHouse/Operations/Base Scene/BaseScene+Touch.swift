//
//  BaseScene+Touch.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import Engine

/// Extends the base scene for handling the touch screen events. Only found on iOS or iPadOS
extension BaseScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    var touchControlInputNode: TouchControlInputSource {
        return sceneManager.gameInput.nativeControlInputSource as! TouchControlInputSource
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Setup Touch Handling
    // -----------------------------------------------------------------
    
    func addTouchInputToScene() {
        
        guard let camera: SKCameraNode = camera else {
            fatalError("Touch input controls can only be added to a scene that has an associated camera.")
        }
        
        // Ensure the touch input source is not associated any other parent.
        touchControlInputNode.removeFromParent()
        
        if self is LevelScene {
            
            // Ensure the control node fills the scene's size.
            touchControlInputNode.size = size
            
            // Center the control node on the camera.
            touchControlInputNode.position = .zero
            
            // Assign a `zPosition` that is above in-game elements, but below the top layer where buttons are added.
            touchControlInputNode.zPosition = WorldLayerPositioning.top.rawValue - CGFloat(1.0)
            
            // Add the control node to the camera node so the controls remain stationary as the camera moves.
            camera.addChild(touchControlInputNode)
            
            // Make sure the controls are visible.
            touchControlInputNode.hideThumbStickNodes = false
        }
    }
}
