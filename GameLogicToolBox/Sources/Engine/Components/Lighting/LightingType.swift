//
//  LightingType.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 17/12/2022.
//

import Foundation

public enum LightingType: UInt32, CaseIterable {
    
    case environment
    case player
    case furniture
    
    public var categoryMask: UInt32 {
        
        var category: UInt32
        
        switch self {
        case .environment:
            category = 1
        case .player:
            category = 1
        case .furniture:
            category = 1
        }
        
        return category
    }
    
    public var shadowedBitMask: UInt32 {
        
        var shadow: UInt32
        
        switch self {
        case .environment:
            shadow = 1
        case .player:
            shadow = 0
        case .furniture:
            shadow = 1
        }
        
        return shadow
    }
    
    public var shadowCastBitMask: UInt32 {
        var shadow: UInt32
        
        switch self {
        case .environment:
            shadow = 1
        case .player:
            shadow = 0
        case .furniture:
            shadow = 1
        }
        
        return shadow
    }
}
