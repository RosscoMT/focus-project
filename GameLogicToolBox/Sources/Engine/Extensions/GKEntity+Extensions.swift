//
//  GKEntity+Extensions.swift
//  
//
//  Created by Ross Viviani on 11/10/2022.
//

import GameplayKit

/// Convenience methods for GKEntity
public extension GKEntity {
    
    func addComponents(_ components: [GKComponent]) {
        
        for component in components {
            self.addComponent(component)
        }
    }
}
