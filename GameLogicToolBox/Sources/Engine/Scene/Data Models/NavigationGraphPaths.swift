//
//  NavigationGraphPaths.swift
//  
//
//  Created by Ross Viviani on 11/04/2023.
//

import Foundation

// Sole purpose of storing key information relating to navigation paths used in SKScenes
public struct NavigationGraphPaths: Decodable {
    
    public enum Orientation: String, Decodable {
        case verticle
        case horizontal
        case diagonal
    }
    
    public let name: String
    public let forwardDirection: Bool
    public let isCyclical: Bool
    public let orientation: Orientation
}
