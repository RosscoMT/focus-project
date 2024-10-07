//
//  KeyboardControlInputSource.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import simd
import SpriteKit
import Engine

class KeyboardControlInputSource: GenericInputSourceDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - Local Properties
    // -----------------------------------------------------------------
    
    typealias Controls = GameplayConfiguration.Keyboard.Controls

    var currentDisplacement: SIMD2<Float> = SIMD2<Float>()
    var pressedKeys: Set<Character> = Set<Character>()
    
    
    // -----------------------------------------------------------------
    // MARK: - GenericInputSourceDelegate
    // -----------------------------------------------------------------
    
    weak var delegate: ControlInputSourceDelegate? {
        didSet {
            resetControlState()
        }
    }
    
    weak var gameStateDelegate: ControlInputSourceGameStateDelegate? {
        didSet {
            resetControlState()
        }
    }
    
    let allowsStrafing: Bool = false
    
    
    // -----------------------------------------------------------------
    // MARK: - Mouse Control Handling
    // -----------------------------------------------------------------

    func handleMouseDownEvent(_ event: GameEvent) {
        gameStateDelegate?.controlInputDownEvent(event, type: .mouse)
    }
    
    func handleLongMouseDownEvent(_ event: GameEvent, input: GameInput.Action) {
        gameStateDelegate?.controlInputDownLongPressEvent(event, input, type: .mouse)
    }
    
    func handleMouseUpEvent(_ event: GameEvent) {
        gameStateDelegate?.controlInputUpEvent(event, type: .mouse)
    }
    
    func handleMouseDragEvent(_ event: GameEvent) {
        gameStateDelegate?.controlInputDragged(with: event, type: .mouse)
    }
    
    func handleMouseDoubleTapEvent(_ event: GameEvent) {
        gameStateDelegate?.controlDoubleTapEvent(event)
    }
    
    func handleMousePinchGesture(_ gesture: NSMagnificationGestureRecognizer) {
        gameStateDelegate?.controlInputPinchGesture(gesture, type: .mouse)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Keyboard Control Handling
    // -----------------------------------------------------------------
    
    // The logic matching a key press to `ControlInputSourceDelegate` calls.
    func handleKeyDown(forCharacter character: Character) {
        
        // Ignore repeat input.
        if pressedKeys.contains(character) {
            return
        }
        
        pressedKeys.insert(character)
         
        if let relativeDisplacement: SIMD2<Float> = Controls.direction(character) {
            
            // Add to the `currentDisplacement` to track the overall displacement.
            currentDisplacement += relativeDisplacement
            
            // Forward or backward displacement, else Rotational displacement.
            if KeyboardControls.isForwardOrBackwardsMovement(relativeDisplacement) {
                delegate?.inputSource(self, didUpdateWithRelativeDisplacement: currentDisplacement)
            } else {
                delegate?.inputSource(self, didUpdateWithRelativeAngularDisplacement: currentDisplacement)
            }
            
//            // Game focus navigation relies on strict 2D coordinates. Translate the relative input into directional coordinates.
//            let directionalVector: SIMD2<Float> = SIMD2<Float>(x: -relativeDisplacement.y, y: relativeDisplacement.x)
//            
//            if let direction: ControlInputDirection = ControlInputDirection(vector: directionalVector) {
//                gameStateDelegate?.controlInput(self, didSpecifyDirection: direction)
//            }
        } else {
            
            // Account for the other possible kinds of actions.
            switch Controls.actionKey(character) {
            case .toggleInfo, .togglePhysics:
                gameStateDelegate?.controlInputToggleDebug(character)
            default:
                return
            }
        }
    }
    
    // Handle the logic matching when a key is released to `ControlInputSource` delegate calls.
    func handleKeyUp(forCharacter character: Character) {
        
        // Ensure the character was accounted for by `handleKeyDown(forCharacter:)`.
        guard pressedKeys.remove(character) != nil else {
            return
        }
        
        // Check if the key has been registered as a movement key
        if let direction: SIMD2<Float> = Controls.direction(character) {
            
            // Subtract from the `currentDisplacement` if a displacement key has been released.
            currentDisplacement -= direction
            
            if pressedKeys.isEmpty {
                // Ensure that the `currentDisplacement` is zero if there are no keys pressed.
                currentDisplacement = SIMD2<Float>()
            }
            
            if KeyboardControls.isForwardOrBackwardsMovement(direction) {
                delegate?.inputSource(self, didUpdateWithRelativeDisplacement: currentDisplacement)
            } else {
                delegate?.inputSource(self, didUpdateWithRelativeAngularDisplacement: currentDisplacement)
            }
        } else {
            
            // Process any other action 
            switch Controls.actionKey(character) {
            case .p:
                gameStateDelegate?.controlInputDidTogglePauseState(self)
            default:
                return
            }
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GenericInputSourceDelegate
    // -----------------------------------------------------------------
    
    func resetControlState() {
        
        // Reset the `currentDisplacement` and clear the currently tracked keys.
        currentDisplacement = SIMD2<Float>()
        pressedKeys.removeAll()
        
        delegate?.inputSource(self, didUpdateWithRelativeDisplacement: currentDisplacement)
        delegate?.inputSource(self, didUpdateWithRelativeAngularDisplacement: currentDisplacement)
    }
}
