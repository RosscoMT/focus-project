//
//  GKEntity+Extensions.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 08/06/2023.
//

import Engine
import GameplayKit

extension GKEntity {
    
    /// Return the debug name
    static func debugNodes(entity: FoundationEntity) -> String {
        return entity.entitiesID()
    }
}
