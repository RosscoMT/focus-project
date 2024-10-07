//
//  ControlInputSourceGameStateDelegate.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit

/// Delegate methods for responding to control input that applies to the game as a whole.
public protocol ControlInputSourceGameStateDelegate: AnyObject {
    func controlInputDidSelect(_ inputSource: GenericInputSourceDelegate)
    func controlInput(_ inputSource: GenericInputSourceDelegate, didSpecifyDirection: ControlInputDirection)
    func controlInputDidTogglePauseState(_ inputSource: GenericInputSourceDelegate)
    
    // Handle hardware interaction iOS, MacOS
    func controlInputUpEvent(_ event: GameEvent, type: ControlInputType)
    func controlInputDownLongPressEvent(_ event: GameEvent, _ input: GameInput.Action, type: ControlInputType)
    func controlInputDownEvent(_ event: GameEvent, type: ControlInputType)
    func controlDoubleTapEvent(_ event: GameEvent)
    func controlInputDragged(with event: GameEvent, type: ControlInputType)
    func controlInputPinchGesture(_ gesture: NSMagnificationGestureRecognizer, type: ControlInputType)
    
    #if DEBUG
    func controlInputToggleDebug(_ value: Character)
    #endif
}
