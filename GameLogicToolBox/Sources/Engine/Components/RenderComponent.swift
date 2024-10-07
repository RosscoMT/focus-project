//
//  RenderComponent.swift
//
//
//  Created by Ross Viviani on 23/11/2022.
//

import SpriteKit
import GameplayKit

public class RenderComponent: GKComponent {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    public lazy var spriteNode: SKSpriteNode? = {
        entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKSpriteNode
    }()
    
    
    
    // -----------------------------------------------------------------
    // MARK: - GKComponent
    // -----------------------------------------------------------------
    
    public override func didAddToEntity() {
        spriteNode?.entity = entity
    }
    
    public override func willRemoveFromEntity() {
        spriteNode?.entity = nil
    }
    
    public override class var supportsSecureCoding: Bool {
        return true
    }
}

extension RenderComponent {
    
    public convenience init(node: SKSpriteNode) {
        self.init()
        spriteNode = node
    }
    
    public convenience init(imageNamed: String, scale: CGFloat) {
        self.init()
        spriteNode = SKSpriteNode(imageNamed: imageNamed)
        spriteNode?.setScale(scale)
    }
}
