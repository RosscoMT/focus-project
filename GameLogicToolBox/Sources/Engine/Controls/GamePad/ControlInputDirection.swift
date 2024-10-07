//
//  ControlInputDirection.swift
//  
//
//  Created by Ross Viviani on 13/10/2022.
//

import simd
import SpriteKit

public enum ControlInputDirection: Int {
    
    case up = 0
    case down
    case left
    case right
    
    public init?(vector: SIMD2<Float>) {
        
        // Require sufficient displacement to specify direction.
        guard length(vector) >= 0.5 else {
            return nil
        }
        
        // Take the max displacement as the specified axis.
        if abs(vector.x) > abs(vector.y) {
            self = vector.x > 0 ? .right : .left
        } else {
            self = vector.y > 0 ? .up : .down
        }
    }
}
