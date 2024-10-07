//
//  CGPoint+Extension.swift
//  
//
//  Created by Ross Viviani on 14/04/2023.
//

import Foundation
import simd

public extension CGPoint {
    
    func vectorFloatPoint() -> vector_float2 {
        return vector_float2.init(x: Float(self.x), y: Float(self.y))
    }
    
    static func distanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    static func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPoint.distanceSquared(from: from, to: to))
    }
}
