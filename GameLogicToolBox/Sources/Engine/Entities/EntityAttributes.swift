//
//  EntityAttributes.swift
//
//
//  Created by Ross Viviani on 27/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit

/// An abstracted struct which is used to create an entity
public struct EntityAttributes {
    
    // The size to use for the entities animation textures.
    public var textureSize: CGSize
    
    // Textures used by entities appearState to show during appearing in the scene.
    public var appearTextures: [CompassDirection: SKTexture]?
    
    
    public init(textureSize: CGSize = .zero, appearTextures: [CompassDirection: SKTexture]? = nil) {
        self.textureSize = textureSize
        self.appearTextures = appearTextures
    }
}
