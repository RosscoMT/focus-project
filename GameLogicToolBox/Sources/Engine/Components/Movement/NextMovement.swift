//
//  NextMovement.swift
//
//
//  Created by Ross Viviani on 22/11/2023.
//

import Foundation

public struct NextMovement {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    public let displacement: SIMD2<Float>
    public let isRelativeToOrientation: Bool
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    public init(displacement: SIMD2<Float>, relativeToOrientation: Bool = false) {
        self.displacement = displacement
        self.isRelativeToOrientation = relativeToOrientation
    }
}
