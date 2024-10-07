//
//  GKComponent+Node.swift
//  valsrevenge
//
//  Created by Ross Viviani on 04/02/2023.
//

import SpriteKit
import GameplayKit

public extension GKComponent {
    
    var componentNode: SKNode {
        
        var node: SKNode = SKNode()
        
        if let componentNode = entity?.component(ofType: GKSKNodeComponent.self)?.node {
            node = componentNode
        } else if let componentNode = entity?.component(ofType: RenderComponent.self)?.spriteNode {
            node = componentNode
        }
        
        return node
    }
}
