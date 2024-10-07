//
//  DragControls.swift
//  
//
//  Created by Ross Viviani on 08/07/2023.
//

import Foundation
import SpriteKit

public struct DragControls {
    
    
    /// Used for processing panning action on both x and y axis
    ///  - Parameters:
    ///  - lastPosition: The last known position of the drag gesture, this is used for calculating the next execution of this function. This variable will also be updated upon
    ///  - currentLocation: The new location of the cursor
    ///  - speed: The pace in which the panning moves the camera
    ///  - debugReporting: Print any debug information
    ///  - Returns: An action with the calculated panning movement
    static public func panScene(lastPosition: inout CGPoint, currentLocation: CGPoint, speed: TimeInterval, _ debugReporting: Bool = false) -> SKAction {
        
        // Set lastPosition as current location, if initial value is zero
        if lastPosition == .zero {
            lastPosition = currentLocation
        }
        
        // Calculated x and y changes
        var xValueChange: CGFloat = 0
        var yValueChange: CGFloat = 0
        
        // Move the scene by the x axis
        if currentLocation.x > lastPosition.x {
            xValueChange = currentLocation.x - lastPosition.x
        } else {
            xValueChange = (lastPosition.x - currentLocation.x) * -1
        }
        
        // Move the scene by the y axis
        if currentLocation.y > lastPosition.y {
            yValueChange = currentLocation.y - lastPosition.y
        } else {
            yValueChange = (lastPosition.y - currentLocation.y) * -1
        }
       
        // Access and store current location from the scene for the next execution
        defer {
            lastPosition = currentLocation
        }
        
        // Display pan scene calculations
        if debugReporting {
            print("LastPosition \(lastPosition) current \(currentLocation), changeby: \(xValueChange)")
        }
        
        return .moveBy(x: xValueChange, y: yValueChange, duration: speed)
    }
}
