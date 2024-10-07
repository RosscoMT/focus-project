//
//  BoundryComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 11/08/2023.
//

import GameplayKit
import SpriteKit
import Engine

/// Adds a visual boundry box around a node
class BoundaryComponent: GKComponent {
    
    typealias FurnitureConfig = GameplayConfiguration.Level.Furniture
    
    var bufferNode: SKSpriteNode?
    var intersecting: Bool = false

    /// Add bountry box to sit around the node
    func addBoundryBox() {
        bufferNode = SKNode.factoryNode(rect: .init(origin: .zero,
                                                    size: componentNode.frame.insetBy(dx: -componentNode.frame.size.width, dy: -componentNode.frame.size.height).size),
                                        colour: FurnitureConfig.boundaryBoxEnabled)
        componentNode.addChild(bufferNode!)
    }
    
    /// Remove the bountry box
    func removeBoundryBox() {
        componentNode.children.forEach({$0.removeFromParent()})
    }
    
    func recolourBoundryBox(_ result: Bool) {
        
        // Cache the intersecting value
        intersecting = result
        
        // Recolour the boundary based on the configuration settings
        bufferNode?.color = result ? FurnitureConfig.boundaryBoxDisabled : FurnitureConfig.boundaryBoxEnabled
    }
    
    /// Generates the furniture node with its boundary box
    /// - Parameters:
    ///   - selectedNode: The furniture node requesting the boundary box
    ///   - position: The position of the boundary box
    /// - Returns: The generated boundary box
    static func generateNodeWithBoundaryBox(node: SKNode, position: CGPoint) -> SKNode {
        
        guard let node = node.entity?.component(ofType: RenderComponent.self)?.spriteNode else {
            fatalError()
        }

        let calculatedRect = CGRect(origin: position,
                                    size: node.frame.insetBy(dx: -node.size.width, dy: -node.size.height).size)
        
        return .factoryNode(rect: calculatedRect)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
