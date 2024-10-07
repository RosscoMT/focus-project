//
//  Geometry+Extensions.swift
//
//
//  Created by Ross Viviani on 21/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//
//  A series of extensions to provide convenience interoperation between `CGPoint` representations of geometric points (common in SpriteKit) and `SIMD2<Float>` representations of points (common in GameplayKit).


import CoreGraphics
import simd

// Extend `CGPoint` to add an initializer from a `SIMD2<Float>` representation of a point.
public extension CGPoint {
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    // Initialize with a `SIMD2<Float>` type.
    init(_ point: SIMD2<Float>) {
        self.init()
        x = CGFloat(point.x)
        y = CGFloat(point.y)
    }
}

// Extend `SIMD2<Float>` to add an initializer from a `CGPoint`.
public extension SIMD2 where Scalar == Float {
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    // Initialize with a `CGPoint` type.
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
}

// Extend `SIMD2<Float>` to declare conformance to the `Equatable` protocol. The conformance to the protocol is provided by the `==` operator function below.
 

// An equality operator function to determine if two `SIMD2<Float>`s are the same.
public func ==(lhs: SIMD2<Float>, rhs: SIMD2<Float>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

// Extend `SIMD2<Float>` to provide a convenience method for working with pathfinding graphs.
public extension SIMD2 where Scalar == Float {
    
    // Calculates the nearest point to this point on a line from `pointA` to `pointB`.
    func nearestPointOnLineSegment(lineSegment: (startPoint: SIMD2<Float>, endPoint: SIMD2<Float>)) -> SIMD2<Float> {
        
        // A vector from this point to the line start.
        let vectorFromStartToLine: SIMD2<Float> = self - lineSegment.startPoint
        
        // The vector that represents the line segment.
        let lineSegmentVector: SIMD2<Float> = lineSegment.endPoint - lineSegment.startPoint
        
        // The length of the line squared.
        let lineLengthSquared: Float = distance_squared(lineSegment.startPoint, lineSegment.endPoint)
        
        // The amount of the vector from this point that lies along the line.
        let projectionAlongSegment: Float = dot(vectorFromStartToLine, lineSegmentVector)
        
        // Component of the vector from the point that lies along the line.
        let componentInSegment: Float = projectionAlongSegment / lineLengthSquared
        
        // Clamps the component between [0 - 1].
        let fractionOfComponent: Float = Swift.max(0, Swift.min(1, componentInSegment))
        
        return lineSegment.startPoint + lineSegmentVector * fractionOfComponent
    }
}
