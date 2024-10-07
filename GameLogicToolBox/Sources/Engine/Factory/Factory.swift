//
//  File.swift
//  
//
//  Created by Ross Viviani on 27/01/2024.
//

import GameplayKit
import SpriteKit

final public class Factory {
    
    public struct FactoryAgent {
        let mass: Float
        let maxAcceleration: Float
        let maxSpeed: Float
        
        public init(mass: Float, maxAcceleration: Float, maxSpeed: Float) {
            self.mass = mass
            self.maxAcceleration = maxAcceleration
            self.maxSpeed = maxSpeed
        }
    }
}

extension GKAgent2D {
    
    /// Factory create GKAgent2D with custom delegate, node and config settings
    public func factoryAgent(entity: GKEntity?, config: Factory.FactoryAgent) {
        
        if let node = entity?.component(ofType: RenderComponent.self)?.spriteNode, let delegate = entity as? any GKAgentDelegate {
            self.delegate = delegate
            self.mass = config.mass
            self.maxAcceleration = config.maxAcceleration
            self.maxSpeed = config.maxSpeed
            self.radius = Float(node.frame.size.width / 2)
            self.position = node.position.vectorFloatPoint()
            self.speed = 0
        }
    }
}
