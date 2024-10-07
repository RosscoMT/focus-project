//
//  FoundationEntity.swift
//  
//
//  Created by Ross Viviani on 11/04/2023.
//

import SpriteKit
import GameplayKit

open class FoundationEntity: GKEntity {
    public weak var delegate: EntityDelegate?
    private var entityID: UUID = .init()
    
    // Remove entity and node from level
    public func removeEntity(node: SKNode?) {
        delegate?.removeEntity(entity: self)
        node?.removeFromParent()
    }
    
    public func entitiesID() -> String {
        return entityID.uuidString
    }
    
    public lazy var componentNode: SKNode = {
        
        var node: SKNode = SKNode()
        
        if let componentNode = self.component(ofType: GKSKNodeComponent.self)?.node {
            node = componentNode
        } else if let componentNode = self.component(ofType: RenderComponent.self)?.spriteNode {
            node = componentNode
        }
        
        return node
    }()
}
