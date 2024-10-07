//
//  SKScene+Extension.swift
//  
//
//  Created by Ross Viviani on 17/05/2023.
//

import Foundation
import SpriteKit

public extension SKScene {
    
    // Filter scenes assets for nodes at path
    func filteredNodes(path: String) -> [SKNode] {
        
        var nodes: [SKNode] = []
        
        // Scan level for any nodes that are till points
        self.enumerateChildNodes(withName: path, using: { node, stop in
            nodes.append(node)
        })
        
        return nodes
    }
}
