//
//  InputComponent.swift
//  Coffee House
//
//  Created by Ross Viviani on 12/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import SpriteKit
import GameplayKit
import Engine

/// A GKComponent that enables an entity to accept control input from device-specific sources.
class InputComponent: GKComponent, ControlInputSourceDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - Types
    // -----------------------------------------------------------------
    
    struct InputState {
        var translation: NextMovement?
        var rotation: NextMovement?
        var allowsStrafing = false
        
        static let noInput = InputState()
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // `InputComponent` has the ability to ignore input when disabled. This is used to prevent the player from moving or firing while being attacked.
    var isEnabled = true {
        didSet {
            if isEnabled {
                // Apply the current input state to the movement and beam components.
                applyInputState(state: state)
            } else {
                // Apply a state of no input to the movement and beam components.
                applyInputState(state: InputState.noInput)
            }
        }
    }
    
    var state = InputState() {
        didSet {
            if isEnabled {
                applyInputState(state: state)
            }
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - ControlInputSourceDelegate
    // -----------------------------------------------------------------
    
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateDisplacement displacement: SIMD2<Float>) {
        state.translation = NextMovement(displacement: displacement)
    }
    
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateAngularDisplacement angularDisplacement: SIMD2<Float>) {
        state.rotation = NextMovement(displacement: angularDisplacement)
    }
    
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateWithRelativeDisplacement relativeDisplacement: SIMD2<Float>) {
        
        // Create a `MovementKind` instance indicating whether the displacement should translate the entity forwards or backwards from the direction it is facing.
        state.translation = NextMovement(displacement: relativeDisplacement, relativeToOrientation: true)
    }
    
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateWithRelativeAngularDisplacement relativeAngularDisplacement: SIMD2<Float>) {
        
        // Create a `MovementKind` instance indicating whether the displacement should rotate the entity clockwise or counter-clockwise from the direction it is facing.
        state.rotation = NextMovement(displacement: relativeAngularDisplacement, relativeToOrientation: true)
    }
    
    func inputSourceDidBegin(_ controlInputSource: GenericInputSourceDelegate) {
        state.allowsStrafing = controlInputSource.allowsStrafing
    }
    
    func inputSourceDidFinish(_ controlInputSource: GenericInputSourceDelegate) {
      
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Convenience
    // -----------------------------------------------------------------
    
    func applyInputState(state: InputState) {
        if let movementComponent: MovementComponent = entity?.component(ofType: MovementComponent.self) {
            movementComponent.allowsStrafing = state.allowsStrafing
            movementComponent.nextRotation = state.rotation
            movementComponent.nextTranslation = state.translation
        }
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
