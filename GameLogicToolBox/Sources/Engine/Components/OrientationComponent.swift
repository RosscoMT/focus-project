//
//  OrientationComponent.swift
//
//
//  Created by Ross Viviani on 23/11/2022.
//

import SpriteKit
import GameplayKit

/// REMEMBER - Velocity is not seen with SKActions as it does not directly affect the agent. Hence the code relating to the characters direction will not detect a change in direction. You will need to set the direction manually for the time being.
/// Bots direction in degrees - 0 = East, 90 = North, 180 = West, 270 = South

/// A GKComponent that enables an animated entity to track its current orientation (i.e. the direction it is facing). This information is used when choosing an appropriate animation.
public class OrientationComponent: GKComponent {

    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    public var zRotation: CGFloat = 0.0 {
        didSet {
            let twoPi = CGFloat(Double.pi * 2)
            zRotation = (zRotation + twoPi).truncatingRemainder(dividingBy: twoPi)
        }
    }
    
    public var compassDirection: CompassDirection {
        get {
            return CompassDirection(zRotation: zRotation)
        }
        
        set {
            zRotation = newValue.zRotation
        }
    }
    
    /// Calculates the angle between the current bot's location and destinations
    /// - Parameter node: The node you want the angle to be calculated to
    public func adjustRotation(_ node: CGPoint) {
        
        // Calculate the angle between the current angle and the destination
        let destinationOrientation = NodeNavigation.destinationAngle(valueOne: componentNode.position,
                                                                     valueTwo: node)
        zRotation = destinationOrientation
    }
    
    /// Sets a new direction of the entity
    /// Coordinates: North - 0, West - 90, South - 180, East - 360
    /// - Parameters:
    ///   - lowest: Lowest number of the range
    ///   - higest: Highest number of the range
    public func newDirection(_ lowest: Int = 0, _ higest: Int = 360) {
        self.zRotation = CGFloat(GKRandomDistribution(lowestValue: lowest, highestValue: higest).nextInt())
    }
  
    /// Sets the bots direction to 180º in the opposite direction
    public func oppositeDirection() {
        self.zRotation = (self.zRotation + 180).truncatingRemainder(dividingBy: 360)
    }
}
