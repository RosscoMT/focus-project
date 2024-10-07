//
//  LevelScene+PhysicsContact.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 11/03/2023.
//

import SpriteKit
import GameplayKit
import Engine

struct CharacterPhysics: Hashable {
    let entity: GKEntity
    let contact: PhysicsBody
    let timestamp: TimeInterval
}

extension LevelScene: SKPhysicsContactDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - SKPhysicsContactDelegate
    // -----------------------------------------------------------------
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactData = contactType(contact)
        
        if let entity = contactData.entity, let contact = contactData.type {
            physicContacts.insert(.init(entity: entity, contact: contact, timestamp: GeneralTools.currentTimeStamp()))
            
            switch stateMachine.currentState {
            case is LevelSceneEditorState:
                editorModePhysicsContact(item: entity)
            default:
                return
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        let contactData = contactType(contact)
        
        if let entity = contactData.entity, let contact = contactData.type, let entry = physicContacts.filter({$0.entity == entity}).filter({$0.contact == contact}).first {
            physicContacts.remove(entry)
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    private func contactType(_ contact: SKPhysicsContact) -> (entity: GKEntity?, type: PhysicsBody?) {
        
        let categoryBitMaskA = contact.bodyA.categoryBitMask
        let categoryBitMaskB = contact.bodyB.categoryBitMask
        
        switch categoryBitMaskA | categoryBitMaskB {
            
        case PhysicsBody.player.categoryBitMask | PhysicsBody.furniture.categoryBitMask:
            
            if let playerNode = contact.contactType(categoryBitMask: PhysicsBody.player.categoryBitMask) {
                return (playerNode, .furniture)
            }
        case PhysicsBody.furniture.categoryBitMask | PhysicsBody.wall.categoryBitMask:
            
            if let furniture = contact.contactType(categoryBitMask: PhysicsBody.furniture.categoryBitMask) {
                return (furniture, .wall)
            }
        case PhysicsBody.furniture.categoryBitMask | PhysicsBody.customer.categoryBitMask:
            
            if let character = contact.contactType(categoryBitMask: PhysicsBody.customer.categoryBitMask) {
                return (character, .furniture)
            }
        case PhysicsBody.wall.categoryBitMask | PhysicsBody.customer.categoryBitMask:
            
            if let character = contact.contactType(categoryBitMask: PhysicsBody.customer.categoryBitMask) {
                return (character, .wall)
            }
        case PhysicsBody.secondaryFurniture.categoryBitMask | PhysicsBody.customer.categoryBitMask:
            
            if let character = contact.contactType(categoryBitMask: PhysicsBody.customer.categoryBitMask) {
                return (character, .secondaryFurniture)
            }
        default:
            return (nil, nil)
        }
        
        return (nil, nil)
    }
}
