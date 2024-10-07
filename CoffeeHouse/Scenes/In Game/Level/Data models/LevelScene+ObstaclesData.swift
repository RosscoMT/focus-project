//
//  ObstaclesData.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 27/05/2023.
//

import SpriteKit

extension LevelScene {
    
    // Data model used soley for transporting obstical information
    struct ObstaclesData {
        let start: CGPoint
        let destination: SKNode
        let sprite: SKNode
        let overlappingFiltering: Bool
        let filter: [String]
    }
}
