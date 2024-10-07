//
//  Direction.swift
//  
//
//  Created by Ross Viviani on 22/04/2023.
//

import Foundation

public enum Direction: CaseIterable {
    case up
    case down
    case left
    case right
    
    // Return random direction
    static public func random(range: Int) -> [Direction] {
        return Array([Direction.right, Direction.left, Direction.up, Direction.down].shuffled().prefix(range))
    }
    
    // Convert string to direction
    static public func direction(from: String) -> Direction {
        
        switch from {
        case "up":
            return .up
        case "down":
            return .down
        case "left":
            return .left
        case "right":
            return .right
        default:
            return Direction.allCases.randomElement()!
        }
    }
}
