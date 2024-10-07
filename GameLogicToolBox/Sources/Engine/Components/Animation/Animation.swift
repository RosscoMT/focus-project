//
//  Animation.swift
//  CoffeeHouse(iOS)
//
//  Created by Ross Viviani on 16/06/2023.
//

import SpriteKit
import GameplayKit

/// All of the information needed to animate an entity and its shadow for a given animation state and direction.
public struct Animation<T: RawRepresentable<String> & Equatable> {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    /// The animation state represented in this animation. Because animation states will differ between games, this variable has been left with a generic enum type to allow flexible loading from the projects side not packages side.
    public let animationState: T
    
    /// The direction the entity is facing in this animation.
    public let compassDirection: CompassDirection
    
    /// The SKTextures which make up this animation which will be cycled through.
    public let textures: [SKTexture]
    
    /// The offset into the textures array to use as the first frame of the animation. Defaults to zero, but will be updated if a copy of this animation decides to offset the starting frame to continue smoothly from the end of a previous animation.
    public var frameOffset = 0
    
    /// An array of textures that runs from the animation's frameOffset to its end, followed by the textures from its start to just before the frameOffset
    public var offsetTextures: [SKTexture] {
        if frameOffset == 0 {
            return textures
        }
        let offsetToEnd = Array(textures[frameOffset..<textures.count])
        let startToBeforeOffset = textures[0..<frameOffset]
        return offsetToEnd + startToBeforeOffset
    }
    
    public let repeatTexturesForever: Bool
    
    // The name of an optional action for this entity's shadow, loaded from an action file.
    public let shadowActionName: String?
    
    // The optional action for this entity's shadow, loaded from an action file.
    public let shadowAction: SKAction?
    
    public init(animationState: T, compassDirection: CompassDirection, textures: [SKTexture], frameOffset: Int = 0, repeatTexturesForever: Bool, shadowActionName: String?, shadowAction: SKAction?) {
        self.animationState = animationState
        self.compassDirection = compassDirection
        self.textures = textures
        self.frameOffset = frameOffset
        self.repeatTexturesForever = repeatTexturesForever
        self.shadowActionName = shadowActionName
        self.shadowAction = shadowAction
    }
}
