//
//  AnimationComponent.swift
//  
//
//  Created by Ross Viviani on 25/11/2023.
//

import SpriteKit
import GameplayKit

/// A GKComponent that provides and manages the actions used to animate characters on screen as they move through different states and face different directions. AnimationComponent is supported by a structure called Animation that encapsulates information about an individual animation.
public struct AnimationConfig {
    
    // The key to use when adding an optional action to the entity's shadow.
    public static let shadowActionKey: String = "shadowAction"
    
    // The key to use when adding a texture animation action to the entity's body.
    public static let textureActionKey: String = "textureAction"
    
    // The time to display each frame of a texture animation.
    public static let timePerFrame: TimeInterval = TimeInterval(1.0 / 10.0)
}

public class AnimationComponent<T: RawRepresentable<String> & Hashable & Equatable>: GKComponent {
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // The most recent animation state that the animation component has been requested to play, but has not yet started playing.
    public var requestedAnimationState: T?
    
    // The node on which animations should be run for this animation component.
    public let node: SKSpriteNode
    
    // The node for the entity's shadow (to be set by the entity if needed).
    public var shadowNode: SKSpriteNode?
    
    // The current set of animations for the component's entity.
    public var animations: [T: [CompassDirection: Animation<T>]]
    
    // The animation that is currently running.
    public var currentAnimation: Animation<T>?
    
    // The length of time spent in the current animation state and direction.
    public var elapsedAnimationDuration: TimeInterval = 0.0
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    public init(textureSize: CGSize, animations: [T: [CompassDirection: Animation<T>]]) {
        node = SKSpriteNode(texture: nil, size: textureSize)
        self.animations = animations
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // -----------------------------------------------------------------
    // MARK: - GKComponent Life Cycle
    // -----------------------------------------------------------------
    
    public override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        
        // If an animation has been requested, run the animation.
        if let animationState: T = requestedAnimationState {
            
            guard let orientationComponent: OrientationComponent = entity?.component(ofType: OrientationComponent.self) else {
                fatalError("An AnimationComponent's entity must have an OrientationComponent.")
            }
            
            runAnimationForAnimationState(animationState: animationState,
                                          compassDirection: orientationComponent.compassDirection,
                                          deltaTime: deltaTime)
            
            requestedAnimationState = nil
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - Character Animation
    // -----------------------------------------------------------------
    
    public func runAnimationForAnimationState(animationState: T, compassDirection: CompassDirection, deltaTime: TimeInterval) {
        
        // Update the tracking of how long we have been animating.
        elapsedAnimationDuration += deltaTime
        
        // Check if we are already running this animation. There's no need to do anything if so.
        if currentAnimation != nil && currentAnimation!.animationState == animationState && currentAnimation!.compassDirection == compassDirection {
            return
        }
        
        /*
         Retrieve a copy of the stored animation for the requested state and compass direction.
         `Animation` is a structure - i.e. a value type - so the `animation` variable below
         will contain a unique copy of the animation's data.
         We request this copy as a variable (rather than a constant) so that the
         `animation` variable's `frameOffset` property can be modified later in this method
         if we choose to offset the animation's start point from zero.
         */
        guard let unwrappedAnimation: Animation = animations[animationState]?[compassDirection] else {
            print("Unknown animation for state \(animationState.rawValue), compass direction \(compassDirection.rawValue).")
            return
        }
        
        var animation: Animation = unwrappedAnimation
        
        // Check if the action for the shadow node has changed.
        if currentAnimation?.shadowActionName != animation.shadowActionName {
            
            // Remove the existing shadow action if it exists.
            shadowNode?.removeAction(forKey: AnimationConfig.shadowActionKey)
            
            // Reset the node's position in its parent (it may have been animating with a move action).
            shadowNode?.position = CGPoint.zero
            
            // Reset the node's scale (it may have been changed with a resize action).
            shadowNode?.xScale = 1.0
            shadowNode?.yScale = 1.0
            
            // Add the new shadow action to the shadow node if an action exists.
            if let shadowAction: SKAction = animation.shadowAction {
                shadowNode?.run(SKAction.repeatForever(shadowAction), withKey: AnimationConfig.shadowActionKey)
            }
        }
        
        // Remove the existing texture animation action if it exists.
        node.removeAction(forKey: AnimationConfig.textureActionKey)
        
        // Create a new action to display the appropriate animation textures.
        let texturesAction: SKAction
        
        // If the new animation only has a single frame, create a simple "set texture" action.
        if animation.textures.count == 1 {
            texturesAction = SKAction.setTexture(animation.textures.first!)
        } else {
            
            if currentAnimation != nil && animationState == currentAnimation!.animationState {
                /*
                 We have just changed facing direction within the same animation state.
                 To make the animation feel smooth as we change direction,
                 begin the animation for the new direction on the frame after
                 the last frame displayed for the old direction.
                 This prevents (e.g.) a walk cycle from resetting to its start
                 every time a character turns to the left or right.
                 */
                
                // Work out how many frames of this animation have played since the animation began.
                let numberOfFramesInCurrentAnimation: Int = currentAnimation!.textures.count
                let numberOfFramesPlayedSinceCurrentAnimationBegan: Int = Int(elapsedAnimationDuration / AnimationConfig.timePerFrame)
                
                /*
                 Work out how far into the animation loop the next frame would be.
                 This takes into account the fact that the current animation may have been
                 started from a non-zero offset.
                 */
                animation.frameOffset = (currentAnimation!.frameOffset + numberOfFramesPlayedSinceCurrentAnimationBegan + 1) % numberOfFramesInCurrentAnimation
            }
            
            // Create an appropriate action from the (possibly offset) animation frames.
            if animation.repeatTexturesForever {
                texturesAction = SKAction.repeatForever(SKAction.animate(with: animation.offsetTextures,
                                                                         timePerFrame: AnimationConfig.timePerFrame))
            } else {
                texturesAction = SKAction.animate(with: animation.offsetTextures,
                                                  timePerFrame: AnimationConfig.timePerFrame)
            }
        }
        
        // Add the textures animation to the body node.
        node.run(texturesAction, withKey: AnimationConfig.textureActionKey)
        
        // Remember the animation we are currently running.
        currentAnimation = animation
        
        // Reset the "how long we have been animating" counter.
        elapsedAnimationDuration = 0.0
    }
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    public func updateAnimationByAgent(newState: T, agent: GKAgent2D) {
        
        // Use the agents velecity or current rotation to determine the new rotation
        let newRotation: Float = agent.velocity.x > 0.0 || agent.velocity.y > 0.0 ? atan2(agent.velocity.y, agent.velocity.x) : agent.rotation
        
        // Ensure we have a valid rotation.
        if newRotation.isNaN {
            return
        }
        
        // Assign the new state
        requestedAnimationState = newState
        
        // Assign the new rotation
        self.entity?.component(ofType: OrientationComponent.self)?.zRotation = CGFloat(newRotation)
    }
    
    /// Filter the animation for the coreect type and direction
    public func animation(type: T, withDirection: CompassDirection) -> Animation<T> {
        
        guard let textures = animations[type]?[withDirection] else {
            fatalError("Invalid animation request")
        }
        
        return textures
    }
    
    public override class var supportsSecureCoding: Bool {
        return true
    }
}
