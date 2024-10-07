//
//  WorldLayerPositioning.swift
//
//
//  Created by Ross Viviani on 31/08/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit

// The order of the cases are based on their z-positioning within the games world, the lowest will be added.
enum WorldLayerPositioning: CGFloat {
    case background // The lowest nodes seen
    case furniture
    case characters
    case camera // Views from the sky down
    
    static func sceneAssets(asset: FurnitureType, node: SKNode) {
        
        let zPosition: CGFloat
        
        switch asset {
        case .table, .chair, .counter, .carpet, .plant, .till, .collectionArea, .obstacle, .door:
            zPosition = WorldLayerPositioning.furniture.rawValue
        default:
            fatalError("Unknown scene asset")
        }
        
        node.zPosition = zPosition
    }
}
