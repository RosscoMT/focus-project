//
//  GameControllerInputSource.swift
//
//
//  Created by Ross Viviani on 13/10/2022.
//

import SpriteKit
import GameController
import GameplayKit

/// An implementation of the `GenericInputSourceDelegate` protocol that enables support for `GCController`s on all platforms.
public class GameControllerInputSource: GenericInputSourceDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------

    // `GenericInputSourceDelegate` delegates.
    weak public var gameStateDelegate: ControlInputSourceGameStateDelegate?
    weak public var delegate: ControlInputSourceDelegate?
    
    public let allowsStrafing: Bool = true
    public let gameController: GCController

    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    public init(gameController: GCController) {
        self.gameController = gameController
        
        //registerPauseEvent()
        registerAttackEvents()
        registerMovementEvents()
        registerRotationEvents()
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Gamepad Registration Methods
    // -----------------------------------------------------------------
    
//    private func registerPauseEvent() {
//        gameController.controllerPausedHandler = { [unowned self] _ in
//            self.gameStateDelegate?.controlInputSourceDidTogglePauseState(self)
//        }
//    }
    
    private func registerAttackEvents() {
        
        // A handler for button press events that trigger an attack action.
        let attackHandler: GCControllerButtonValueChangedHandler = { [unowned self] button, _, pressed in
            if pressed {
                self.delegate?.inputSourceDidBegin(self)

                #if os(tvOS)
                if let microGamepad = self.gameController.microGamepad, button == microGamepad.buttonA || button == microGamepad.buttonX {
                    self.gameStateDelegate?.controlInputDidSelect(self)
                }
                #else
                if let gamepad = self.gameController.extendedGamepad, button == gamepad.buttonA || button == gamepad.buttonX {
                    self.gameStateDelegate?.controlInputDidSelect(self)
                }
                #endif
            } else {
                self.delegate?.inputSourceDidFinish(self)
            }
        }
        
        #if os(tvOS)
        // `GCMicroGamepad` button handlers.
        if let microGamepad: GCMicroGamepad = gameController.microGamepad {
            microGamepad.buttonA.pressedChangedHandler = attackHandler
            microGamepad.buttonX.pressedChangedHandler = attackHandler
        }
        #endif
    
        // `GCExtendedGamepad` button handlers.
        if let gamepad: GCExtendedGamepad = gameController.extendedGamepad {
            
            // Assign an action to every button, even if this means that multiple buttons provide the same functionality. It's better to have repeated functionality than to have a button that doesn't do anything.
            gamepad.buttonA.pressedChangedHandler = attackHandler
            gamepad.buttonB.pressedChangedHandler = attackHandler
            gamepad.buttonX.pressedChangedHandler = attackHandler
            gamepad.buttonY.pressedChangedHandler = attackHandler
            gamepad.leftShoulder.pressedChangedHandler = attackHandler
            gamepad.rightShoulder.pressedChangedHandler = attackHandler
        }
        
        // `GCExtendedGamepad` trigger handlers.
        if let extendedGamepad: GCExtendedGamepad = gameController.extendedGamepad {
            extendedGamepad.rightTrigger.pressedChangedHandler = attackHandler
            extendedGamepad.leftTrigger.pressedChangedHandler  = attackHandler
        }
    }
    
    private func registerMovementEvents() {
        
        // An analog movement handler for D-pads and movement thumbsticks.
        let movementHandler: GCControllerDirectionPadValueChangedHandler = { [unowned self] _, xValue, yValue in
            
            // Move toward the direction of the axis.
            let displacement: SIMD2<Float> = SIMD2<Float>(x: xValue, y: yValue)
            
            self.delegate?.inputSource(self, didUpdateDisplacement: displacement)
            
            if let direction: ControlInputDirection = ControlInputDirection(vector: displacement) {
                self.gameStateDelegate?.controlInput(self, didSpecifyDirection: direction)
            }
        }
        
        #if os(tvOS)
        // `GCMicroGamepad` D-pad handler.
        if let microGamepad: GCMicroGamepad = gameController.microGamepad {
            // Allow the gamepad to handle transposing D-pad values when rotating the controller.
            microGamepad.allowsRotation = true
            microGamepad.dpad.valueChangedHandler = movementHandler
        }
        #endif
        
        // `GCGamepad` D-pad handler.
        if let gamepad: GCExtendedGamepad = gameController.extendedGamepad {
            gamepad.dpad.valueChangedHandler = movementHandler 
        }
        
        // `GCExtendedGamepad` left thumbstick.
        if let extendedGamepad: GCExtendedGamepad = gameController.extendedGamepad {
            extendedGamepad.leftThumbstick.valueChangedHandler = movementHandler
        }
    }
    
    private func registerRotationEvents() {
        
        // `GCExtendedGamepad` right thumbstick controls rotational attack independent of movement direction.
        if let extendedGamepad: GCExtendedGamepad = gameController.extendedGamepad {
        
            extendedGamepad.rightThumbstick.valueChangedHandler = { [unowned self] _, xValue, yValue in
                
                // Rotate by the angle formed from the supplied axis.
                let angularDisplacement: SIMD2<Float> = SIMD2<Float>(x: xValue, y: yValue)
                
                self.delegate?.inputSource(self, didUpdateAngularDisplacement: angularDisplacement)
                
                // Attack while rotating. This closely mirrors the behavior of the iOS touch controls.
                if length(angularDisplacement) > 0 {
                    self.delegate?.inputSourceDidBegin(self)
                } else {
                    self.delegate?.inputSourceDidFinish(self)
                }
            }
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GenericInputSourceDelegate
    // -----------------------------------------------------------------
    
    public func resetControlState() {
        
        // Check the current values of the dpad and right thumbstick to see if any direction is currently being requested for focused based navigation. This allows for continuous scrolling while using game controllers.
        guard let dpad: GCControllerDirectionPad = gameController.extendedGamepad?.dpad else {
            return
        }
        
        let dpadDisplacement: SIMD2<Float> = SIMD2<Float>(x: dpad.xAxis.value, y: dpad.yAxis.value)
        
        if let inputDirection: ControlInputDirection = ControlInputDirection(vector: dpadDisplacement) {
            gameStateDelegate?.controlInput(self, didSpecifyDirection: inputDirection)
            return
        }
        
        guard let thumbStick: GCControllerDirectionPad = gameController.extendedGamepad?.leftThumbstick else {
            return
        }
        
        let thumbStickDisplacement: SIMD2<Float> = SIMD2<Float>(x: thumbStick.xAxis.value, y: thumbStick.yAxis.value)
        
        if let inputDirection: ControlInputDirection = ControlInputDirection(vector: thumbStickDisplacement) {
            gameStateDelegate?.controlInput(self, didSpecifyDirection: inputDirection)
        }
    }

}

