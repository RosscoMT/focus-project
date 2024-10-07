//
//  Furniture.swift
//  Coffee House
//
//  Created by Ross Viviani on 12/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import GameplayKit
import Engine

struct FunitureComponents {
    let renderComponent: RenderComponent
    let interactionPadComponent: InteractionPadComponent
    let boundryComponent: BoundaryComponent
}


/// The base entity for the furniture entites
class Furniture: FoundationEntity {
    
    
    // The InteractionPadComponent associated with this entity.
    var interactionPadComponent: InteractionPadComponent {
        
        guard let interactionPadComponent: InteractionPadComponent = component(ofType: InteractionPadComponent.self) else {
            fatalError("A CharacterBot must have an interactionPadComponent.")
        }
        
        return interactionPadComponent
    }
    
    // The RenderComponent associated with this entity.
    var renderComponent: RenderComponent {
        
        guard let renderComponent: RenderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A CharacterBot must have an RenderComponent.")
        }
        
        return renderComponent
    }
    
    // The RenderComponent associated with this entity.
    var boundryComponent: BoundaryComponent {
        
        guard let renderComponent: BoundaryComponent = component(ofType: BoundaryComponent.self) else {
            fatalError("A CharacterBot must have an RenderComponent.")
        }
        
        return renderComponent
    }
    
    lazy var componentList: FunitureComponents = {
        return .init(renderComponent: renderComponent, interactionPadComponent: interactionPadComponent, boundryComponent: boundryComponent)
    }()
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    
    /// Initialiser for creating Furniture with its corrosponding sprite
    /// - Parameters:
    ///   - furnitureType: The furniture type to generate
    ///   - scene: The scene this will be used with
    init(furnitureType: FurnitureType, scene: SKScene) {
        
        super.init()
        
        do {
            
            // Load furniture sprite from asset atlas
            guard let node = try FurnitureSprite.sprite(type: furnitureType) else {
                return
            }
            
            // Loads the sprite as the renders node
            let renderComponent: RenderComponent = RenderComponent(node: node.node)
            renderComponent.spriteNode?.zPosition = WorldLayerPositioning.furniture.rawValue
            
            // Setup the physics components
            let physicsComponent: PhysicsComponent = PhysicsComponent()
            physicsComponent.category = PhysicsCategory.furniture.rawValue
            physicsComponent.shape = PhysicsShape.rect.rawValue
            
            // Add interaction pad based on the direction
            let interactionPadComponent = InteractionPadComponent()
            interactionPadComponent.interactionSides = node.sides ?? 0
            interactionPadComponent.scene = scene
            
            let boundryBox = BoundaryComponent()
    
            addComponents([renderComponent, physicsComponent, interactionPadComponent, boundryBox])
        } catch {
            assertionFailure("Failed to assign SKScene sprite an entity")
        }
    }
    
    static func extractComponent(node: SKNode) -> FunitureComponents {
        return .init(renderComponent: node.component(RenderComponent.self), interactionPadComponent: node.component(InteractionPadComponent.self), boundryComponent: node.component(BoundaryComponent.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
