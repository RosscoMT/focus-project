//
//  SceneOverlay.swift
//
//
//  Created by Ross Viviani on 19/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//
//

import SpriteKit

/// A class dedicated for allowing transparent overlays for scenes ie pause screens, option menus etc
public class SceneOverlay {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    public let backgroundNode: SKSpriteNode
    public let contentNode: SKSpriteNode
    public let nativeContentSize: CGSize
    
    
    // -----------------------------------------------------------------
    // MARK: - Intialization
    // -----------------------------------------------------------------
    
    public init<T: RawRepresentable<String>, O: RawRepresentable<CGFloat>>(fileName: T, zPosition: O) throws {
    
        // Load the scene and get the overlay node from it.
        let contentTemplateNode: SKSpriteNode = SKNode.loadNode(scene: fileName.rawValue, node: "Overlay")
 
        // Create a background node with the same color as the template.
        backgroundNode = SKSpriteNode(color: contentTemplateNode.color, size: contentTemplateNode.size)
        backgroundNode.zPosition = zPosition.rawValue
        
        // Copy the template node into the background node.
        contentNode = contentTemplateNode
        contentNode.position = .zero
        backgroundNode.addChild(contentNode)
        backgroundNode.alpha = 0
        
        // Set the content node to a clear color to allow the background node to be seen through it.
        contentNode.color = .clear
        
        // Store the current size of the content to allow it to be scaled correctly.
        nativeContentSize = contentNode.size
    }
    
    public func updateScale() {
        
        guard let viewSize: CGSize = backgroundNode.scene?.view?.frame.size else {
            return
        }

        // Resize the background node.
        backgroundNode.size = viewSize
        
        // Scale the content so that the height always fits.
        let scale: CGFloat = viewSize.height / nativeContentSize.height
        contentNode.setScale(scale)
    }
}
