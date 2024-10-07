//
//  SKPhysicsContact.swift
//  
//
//  Created by Ross Viviani on 02/08/2023.
//

import GameplayKit

extension SKPhysicsContact {
    
    
    /// Returns the entity relating to the requested category bit mask
    /// - Parameter categoryBitMask: The category bit mask to use
    /// - Returns: The discovered entity
    public func contactType(categoryBitMask: UInt32) -> GKEntity? {
        
        if let node: GKEntity = self.bodyA.categoryBitMask == categoryBitMask ? self.bodyA.node?.entity : self.bodyB.node?.entity {
            return node
        } else {
            return nil
        }
    }
}
