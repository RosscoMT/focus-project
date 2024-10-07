//
//  Simd+Extension.swift
//  
//
//  Created by Ross Viviani on 12/04/2023.
//

import simd
import Foundation

public extension SIMD where Self == vector_float2 {
    
    // Convert and or round vector_float2 as CGPoint
    func point(_ roundedBy: CGFloat = 1) -> CGPoint {
        
        let xValue = (CGFloat(self.x) * roundedBy).rounded()
        let yValue = (CGFloat(self.y) * roundedBy).rounded()
        
        return CGPoint(x: xValue / roundedBy, y: yValue / roundedBy)
    }
}
