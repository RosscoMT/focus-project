//
//  ControlInputSourceDelegate.swift
//
//
//  Created by Ross Viviani on 12/10/2022.
//

import simd

/// Protocols that manage and respond to control input for the game as a whole.
public protocol ControlInputSourceDelegate: AnyObject {
    /**
        Update the `ControlInputSourceDelegate` with new displacement
        in a top down 2D coordinate system (x, y):
            Up:    (0.0, 1.0)
            Down:  (0.0, -1.0)
            Left:  (-1.0, 0.0)
            Right: (1.0, 0.0)
    */
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateDisplacement displacement: SIMD2<Float>)
    
    // Update the `ControlInputSourceDelegate` with new angular displacement denoting both the requested angle, and magnitude with which to rotate. Measured in radians.
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateAngularDisplacement angularDisplacement: SIMD2<Float>)
    
    // Update the `ControlInputSourceDelegate` to move forward or backward relative to the orientation of the entity. Forward:  (0.0, 1.0) Backward: (0.0, -1.0)
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateWithRelativeDisplacement relativeDisplacement: SIMD2<Float>)
    
    // Update the `ControlInputSourceDelegate` with new angular displacement relative to the entity's existing orientation. Clockwise: (-1.0, 0.0) CounterClockwise: (1.0, 0.0)
    func inputSource(_ controlInputSource: GenericInputSourceDelegate, didUpdateWithRelativeAngularDisplacement relativeAngularDisplacement: SIMD2<Float>)
    
    // Instructs the `ControlInputSourceDelegate` to cause the player to attack.
    func inputSourceDidBegin(_ controlInputSource: GenericInputSourceDelegate)
    
    // Instructs the `ControlInputSourceDelegate` to end the player's attack.
    func inputSourceDidFinish(_ controlInputSource: GenericInputSourceDelegate)
}
