//
//  CompassDirection.swift
//  
//
//  Created by Ross Viviani on 23/11/2022.
//

import CoreGraphics
import GLKit

/// An enumeration that converts between rotations (in radians) and 16-point compass point orientations (with east as zero). Used when determining which animation to use for an entity's current orientation.
///
/// The different directions that an animated character can be facing
public enum CompassDirection: Int, CaseIterable, Hashable {
    
    case east = 0, eastByNorthEast, northEast, northByNorthEast
    case north, northByNorthWest, northWest, westByNorthWest
    case west, westBySouthWest, southWest, southBySouthWest
    case south, southBySouthEast, southEast, eastBySouthEast
    
    // The angle of rotation that the orientation represents.
    public var zRotation: CGFloat {
        
        // Calculate the number of radians between each direction.
        let stepSize: CGFloat = CGFloat(Double.pi * 2.0) / CGFloat(CompassDirection.allCases.count)
        return CGFloat(self.rawValue) * stepSize
    }
    
    // Creates a new `FacingDirection` for a given `zRotation` in radians.
    public init(zRotation: CGFloat) {
        
        let twoPi: Double = Double.pi * 2
        
        // Normalize the node's rotation.
        let rotation: Double = (Double(zRotation) + twoPi).truncatingRemainder(dividingBy: twoPi)
        
        // Convert the rotation of the node to a percentage of a circle.
        let orientation: Double = (rotation / twoPi)
        
        // Scale the percentage to a value between 0 and 15.
        let rawFacingValue: Double = round(orientation * 16.0).truncatingRemainder(dividingBy: 16.0)
        
        // Select the appropriate `CompassDirection` based on its members' raw values, which also run from 0 to 15.
        self = CompassDirection(rawValue: Int(rawFacingValue))!
    }
    
    public init(string: String) {
        switch string {
            case "North":
                self = .north
            case "NorthEast":
                self = .northEast
            case "East":
                self = .east
            case "SouthEast":
                self = .southEast
            case "South":
                self = .south
            case "SouthWest":
                self = .southWest
            case "West":
                self = .west
            case "NorthWest":
                self = .northWest
            default:
                fatalError("Unknown or unsupported string - \(string)")
        }
    }
    
    /// Degrees of each compass point
    public func degreesOfCompass() -> CGFloat {
        switch self {
        case .east:
            return CGFloat(GLKMathDegreesToRadians(0))
        case .eastByNorthEast:
            return CGFloat(GLKMathDegreesToRadians(22.5))
        case .northEast:
            return CGFloat(GLKMathDegreesToRadians(45))
        case .northByNorthEast:
            return CGFloat(GLKMathDegreesToRadians(67.5))
        case .north:
            return CGFloat(GLKMathDegreesToRadians(90))
        case .northByNorthWest:
            return CGFloat(GLKMathDegreesToRadians(112.5))
        case .northWest:
            return CGFloat(GLKMathDegreesToRadians(135))
        case .westByNorthWest:
            return CGFloat(GLKMathDegreesToRadians(157.5))
        case .west:
            return CGFloat(GLKMathDegreesToRadians(180))
        case .westBySouthWest:
            return CGFloat(GLKMathDegreesToRadians(202.5))
        case .southWest:
            return CGFloat(GLKMathDegreesToRadians(225))
        case .southBySouthWest:
            return CGFloat(GLKMathDegreesToRadians(247.5))
        case .south:
            return CGFloat(GLKMathDegreesToRadians(270))
        case .southBySouthEast:
            return CGFloat(GLKMathDegreesToRadians(292.5))
        case .southEast:
            return CGFloat(GLKMathDegreesToRadians(315))
        case .eastBySouthEast:
            return CGFloat(GLKMathDegreesToRadians(337.5))
        }
    }
}
