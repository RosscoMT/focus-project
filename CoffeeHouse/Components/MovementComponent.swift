//
//  MovementComponent.swift
//  Coffee House
//
//  Created by Ross Viviani on 12/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import SpriteKit
import GameplayKit
import Engine

class MovementComponent: FoundationComponent<AnimationState> {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // The `OrientationComponent` for this component's entity.
    var orientationComponent: OrientationComponent {
        
        guard let orientationComponent = entity?.component(ofType: OrientationComponent.self) else {
            fatalError("A MovementComponent's entity must have an OrientationComponent")
        }
        
        return orientationComponent
    }
    
    var movementSpeed: CGFloat
    var angularSpeed: CGFloat
    var nextTranslation: NextMovement?
    var nextRotation: NextMovement?
    var allowsStrafing = false
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    override init() {
        movementSpeed = GameplayConfiguration.PlayerBot.movementSpeed
        angularSpeed = GameplayConfiguration.PlayerBot.angularSpeed
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKComponent Life Cycle
    // -----------------------------------------------------------------
  
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Declare local versions of computed properties so we don't compute them multiple times.
        let node = renderComponent.spriteNode!
        let orientationComponent = self.orientationComponent

        var animationState: AnimationState?
        
        if let movement = nextRotation, let newRotation = angleForRotatingNode(node: node, withRotationalMovement: movement, duration: deltaTime)  {
            // Update the node's `zRotation` with new rotation information.
            orientationComponent.zRotation = newRotation
            animationState = .idle
        } else {
            // Clear the rotation if a valid angle could not be created.
            nextRotation = nil
        }
        
        // Next possible nodes position based on incoming gameplay input
        if let movement = nextTranslation, let newPosition = nodesNextPositionPoint(node: node, translation: movement, duration: deltaTime) {
            node.position = newPosition
            
            // If no explicit rotation is being provided, orient in the direction of movement.
            if nextRotation == nil {
                orientationComponent.zRotation = CGFloat(atan2(movement.displacement.y, movement.displacement.x))
            }
            
            // Always request a walking animation, but distinguish between walking forward and backwards based on node's `zRotation`.
            animationState = animationStateForDestination(node: node, destination: newPosition)
        } else {
            // Clear the translation if a valid point could not be created.
            nextTranslation = nil
        }
        
        updateAnimationState(state: animationState)
    }
    
    func updateAnimationState(state: AnimationState?) {
        
        guard let animation = state else {
            return
        }
        
        self.animationComponent.animationStateCanBeOverwritten(newState: animation)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Calculation Methods
    // -----------------------------------------------------------------
    
    // Produces the destination point for the node, based on the provided translation.
    func nodesNextPositionPoint(node: SKNode, translation: NextMovement, duration: TimeInterval) -> CGPoint? {
        
        // No translation if the vector is a zeroVector - due to rotation
        guard translation.displacement != .zero else {
            return nil
        }
        
        var displacement = translation.displacement
        
        // If the translation is relative, the displacement vector needs to be rotated to account for the node's current orientation.
        if translation.isRelativeToOrientation {
            
            guard displacement.x != 0 else {
                return nil
            }
            
            displacement = calculateDisplacementFromRelative(displacement: displacement)
        }
        //moveToDestinationPoint
        //nodesNextPositionPoint
        // Calculate the furthest distance between two points the entity could travel.
        let maxPossibleDistanceToMove = movementSpeed * CGFloat(duration)
        
        // Make sure that the total possible distance that can be travelled by the node is scaled by the the displacement's magnitude. For example, if a user is interacting with a `GameControlInputSource` that is using a thumb-stick to move the player, the actual displacement value would be between 0.0 and 1.0. In that case, we want to move the corresponding node relative to that amount of input.
        let normalizedDisplacement: SIMD2<Float> = length(displacement) > 1.0 ? normalize(displacement) : displacement
        let actualDistanceToMove = CGFloat(length(normalizedDisplacement)) * maxPossibleDistanceToMove
        
        // Find the x and y components of the distance based on the angle.
        let dx = actualDistanceToMove * cos(CGFloat(atan2(displacement.y, displacement.x)))
        let dy = actualDistanceToMove * sin(CGFloat(atan2(displacement.y, displacement.x)))
        
        // Return the final point the entity should move to.
        return CGPoint(x: node.position.x + dx, y: node.position.y + dy)
    }
    
    func angleForRotatingNode(node: SKNode, withRotationalMovement rotation: NextMovement, duration: TimeInterval) -> CGFloat? {
       
        // No rotation if the vector is a zeroVector.
        guard rotation.displacement != .zero else {
            return nil
        }

        if rotation.isRelativeToOrientation {
            
            // Clockwise: (dx: 0.0, dy: -1.0), CounterClockwise: (dx: 0.0, dy: 1.0)
            let rotationComponent = rotation.displacement.y
           
            guard rotationComponent != 0 else {
                return nil
            }
            
            // Add a fixed amount to the node's existing `zRotation` based on the direction of the relative angle.
            let rotationDirection = CGFloat(rotationComponent > 0 ? 1 : -1)
            
            // Calculate the maximum rotation an entity could travel given the duration.
            let maxPossibleRotation = angularSpeed * CGFloat(duration)
            
            // Determine the rotational displacement. In an application with full 2π rotation, the magnitude of the `angularDisplacement` could be used to determine the rate of rotation. Here we are just concerned with the angle.
            let dz = rotationDirection * maxPossibleRotation
            
            // Add to the node's existing rotation.
            return orientationComponent.zRotation + dz
        } else {
            // Determine the angle of the rotational displacement.
            return CGFloat(atan2(rotation.displacement.y, rotation.displacement.x))
        }
    }
    
    // Provides the appropriate animation depending on how the node is moving in reference to its `zRotation`.
    private func animationStateForDestination(node: SKNode, destination: CGPoint) -> AnimationState {
        // Ensures nodes rotation is the same direction as the destination point.
        let isMovingWithOrientation = (orientationComponent.zRotation * atan2(destination.y, destination.x)) > 0
        return isMovingWithOrientation ? .walkForward : .walkBackward
    }
    
    
    // Calculates a new vector by taking a relative displacement and adjusting  the angle to match the initial orientation and requested displacement.
    private func calculateDisplacementFromRelative(displacement: SIMD2<Float>) -> SIMD2<Float> {
        
        // If available use the `nextRotation` for the most recent request, otherwise use current `zRotation`.
        var angleRelativeToOrientation = Float(orientationComponent.zRotation)
      
        // Forward: (dx: 1.0, dy: 0.0), Backward: (dx: -1.0, dy: 0.0)
        if displacement.x < 0 {
            // The entity is moving backwards, add 180 degrees to the angle
            angleRelativeToOrientation += Float(Double.pi)
        }
        
        // Calculate the components of a new vector with direction based off the `angleRelativeToOrientation`.
        let dx = length(displacement) * cos(angleRelativeToOrientation)
        let dy = length(displacement) * sin(angleRelativeToOrientation)

        // Make rotation correspond with relative movement, so that entities can walk and face the same direction.
        if nextRotation == nil {
            let directionFactor = Float(displacement.x)
            nextRotation = NextMovement(displacement: SIMD2<Float>(x: directionFactor * dx, y: directionFactor * dy))
        }
        
        return SIMD2<Float>(x: dx, y: dy)
    }
}
