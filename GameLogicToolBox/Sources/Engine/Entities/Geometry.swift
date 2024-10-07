//
//  Geometry.swift
//  
//
//  Created by Ross Viviani on 05/05/2023.
//

import Foundation

public struct Geometry {
    
    // Calculate the distance between two points
    static public func calculatedDistance(valueOne: Double, valueTwo: Double, distance: Double) -> Bool {
        let calculatedDistance: Double = valueOne > valueTwo ? valueOne - valueTwo : valueTwo - valueOne
        return calculatedDistance < distance ? true : false
    }
}
