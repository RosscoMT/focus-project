//
//  PhysicsComponent.swift
//
//
//  Created by Ross Viviani on 20/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import GameplayKit
import Engine

/// This component is used for attaching physics to a entity with specific configuration information
class PhysicsComponent: GKComponent {
    
    @GKInspectable var category: String = ""
    @GKInspectable var shape: String = ""
    @GKInspectable var isDynamic: Bool = true
    @GKInspectable var mass: CGFloat = 0
    @GKInspectable var restitution: CGFloat = 0
    
    var affectedByGravity: Bool = false
    var allowsRotation: Bool = false
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
 
    override func didAddToEntity() {
        
        guard let bodyCategory = PhysicsBody.forType(PhysicsCategory(rawValue: category)), let sprite = componentNode as? SKSpriteNode else {
            return
        }
        
        // Assign the shape
        switch shape {
        case PhysicsShape.rect.rawValue:
            
            let shapeData: PhysicsCategory.PhysicsBody = (PhysicsCategory(rawValue: category)?.rectBody(size: sprite.size, frame: sprite.frame))!
            
            componentNode.physicsBody = SKPhysicsBody(rectangleOf: shapeData.bodySize, center: shapeData.point)
        case PhysicsShape.circle.rawValue:
            componentNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.height / 2)
        default:
            assertionFailure("Unknown shape")
        }

        // Assign the physics information
        componentNode.physicsBody?.categoryBitMask = bodyCategory.categoryBitMask
        componentNode.physicsBody?.collisionBitMask = bodyCategory.collisionBitMask
        componentNode.physicsBody?.contactTestBitMask = bodyCategory.contactTestBitMask
        componentNode.physicsBody?.affectedByGravity = affectedByGravity
        componentNode.physicsBody?.allowsRotation = allowsRotation
        componentNode.physicsBody?.isDynamic = isDynamic
        componentNode.physicsBody?.mass = mass
        componentNode.physicsBody?.restitution = restitution
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if let scene: LevelScene = componentNode.scene as? LevelScene, let contact = scene.physicContacts.first(where: {$0.entity == entity}), GeneralTools.timeElapsed(timeStamp: contact.timestamp, wait: 0.5) {
            
            guard let mandate = entity as? CharacterBot else {
                return
            }
            
            switch mandate.currentMandate {
            case .wander:
                self.entity?.component(ofType: OrientationComponent.self)?.oppositeDirection()
                scene.physicContacts.remove(contact)
            default:
                return
            }
            
        }
    }
    
    // Require should this be used with the SKScene
    override class var supportsSecureCoding: Bool {
        return true
    }
}
