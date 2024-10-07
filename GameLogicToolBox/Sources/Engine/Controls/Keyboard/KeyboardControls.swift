//
//  KeyboardControl.swift
//  
//
//  Created by Ross Viviani on 12/10/2022.
//

import simd

/// Enum used for calculating the keyboard controls
public enum KeyboardControls {
    
    // These are the unicode references for special keys
    public enum SpecialKeys: Int {
        case up = 0xF700
        case down = 0xF701
        case left = 0xF702
        case right = 0xF703
    }
    
    // 2D movement type
    case forward
    case backward
    case clockwise
    case counterClockwise
    
    public func vector() -> SIMD2<Float> {
        switch self {
        case .forward:
            return SIMD2<Float>(x: 1, y: 0)
        case .backward:
            return SIMD2<Float>(x: -1, y: 0)
        case .clockwise:
            return SIMD2<Float>(x: 0, y: -1)
        case .counterClockwise:
            return SIMD2<Float>(x: 0, y: 1)
        }
    }

    // Detect the time of displacement
    public static func isForwardOrBackwardsMovement(_ displacement: SIMD2<Float>) -> Bool {
        return displacement == KeyboardControls.forward.vector() || displacement == KeyboardControls.backward.vector()
    }
}
