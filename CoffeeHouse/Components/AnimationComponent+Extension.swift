//
//  AnimationComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 26/12/2022.
//

import SpriteKit
import GameplayKit
import Engine

extension AnimationComponent {
    
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    // Check if the current animation can be replaced with new one
    func animationStateCanBeOverwritten(newState: T) {
        
        guard let currentState: AnimationState = currentAnimation?.animationState as? AnimationState, let requestedState: AnimationState = requestedAnimationState as? AnimationState else {
            return
        }
        
        func checkState(state: AnimationState) -> Bool {
            switch state {
            case .idle, .walkForward, .walkBackward:
                return true
            default:
                return false
            }
        }
        
        if checkState(state: currentState) && checkState(state: requestedState) {
            self.requestedAnimationState = newState
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Texture loading utilities
    // -----------------------------------------------------------------
    
    // Returns the first texture in an atlas for a given `CompassDirection`.
    class func firstTextureForOrientation<O: RawRepresentable>(compassDirection: CompassDirection, inAtlas atlas: SKTextureAtlas, withImageIdentifier identifier: O) -> SKTexture {
        
        // Filter for this facing direction, and sort the resulting texture names alphabetically.
        let textureNames: [String] = atlas.textureNames.filter {
            $0.hasPrefix("\(identifier.rawValue)_\(compassDirection.rawValue)_")
        }.sorted()
        
        // Find and return the first texture for this direction.
        return atlas.textureNamed(textureNames.first!)
    }
    
    // Creates a texture action from all textures in an atlas.
    class func actionForAllTexturesInAtlas(atlas: SKTextureAtlas) -> SKAction {
        
        // Sort the texture names alphabetically, and map them to an array of actual textures.
        let textures: [SKTexture] = atlas.textureNames.sorted().map {
            atlas.textureNamed($0)
        }
        
        // Create an appropriate action for these textures.
        if textures.count == 1 {
            return SKAction.setTexture(textures.first!)
        } else {
            return SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: AnimationConfig.timePerFrame))
        }
    }
    
    // Creates an `Animation` from textures in an atlas and actions loaded from file.
    class func animationsFromAtlas<O: RawRepresentable>(atlas: SKTextureAtlas, withImageIdentifier identifier: O, forAnimationState animationState: AnimationState, shadowActionName: String? = nil, repeatTexturesForever: Bool = true, playBackwards: Bool = false) -> [CompassDirection: Animation<T>] {
        
        // Load a shadow action from an actions file if requested.
        let shadowAction: SKAction?
        if let name: String = shadowActionName {
            shadowAction = SKAction(named: name)
        } else {
            shadowAction = nil
        }
        
        // A dictionary of animations with an entry for each compass direction.
        var animations: [CompassDirection: Animation<T>] = [CompassDirection: Animation<T>]()
        
        for compassDirection in CompassDirection.allCases {
            
            // Find all matching texture names, sorted alphabetically, and map them to an array of actual textures.
            let textures: [SKTexture] = atlas.textureNames.filter {
                $0.hasPrefix("\(identifier.rawValue)_\(compassDirection.rawValue)_")
            }.sorted {
                playBackwards ? $0 > $1 : $0 < $1
            }.map {
                atlas.textureNamed($0)
            }
            
            // Create a new `Animation` for these settings.
            animations[compassDirection] = Animation(
                animationState: animationState as! T,
                compassDirection: compassDirection,
                textures: textures,
                frameOffset: 0,
                repeatTexturesForever: repeatTexturesForever,
                shadowActionName: shadowActionName,
                shadowAction: shadowAction
            )
        }
        
        return animations
    }
}
