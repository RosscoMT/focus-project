//
//  LevelSceneNodelDataModel.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 03/07/2023.
//

import SpriteKit

/// Data model contains references to all nodes found in the level
struct LevelSceneModel {
    
    typealias config = GameplayConfiguration.Level
    
    // All the furniture in the scene
    lazy var furniture: [SKNode] = {
        return scene.childNode(name: GameNodes.furniture, baseExtension: config.baseExtension)?.children ?? []
    }()
    
    // All the walls in the scene
    lazy var wall: [SKNode] = {
        return scene.childNode(name: GameNodes.obstacles, baseExtension: config.baseExtension)?.children ?? []
    }()
    
    // All the access points to the scene
    lazy var entryPoints: [SKNode] = {
        return scene.childNode(name: GameNodes.entrance, baseExtension: config.baseExtension)?.children ?? []
    }()
    
    // This is background level
    lazy var board: SKNode = {
        return scene.childNode(name: GameNodes.board, baseExtension: config.baseExtension)!
    }()
    
    // This is items placed in the scene
    lazy var placed: [SKNode] = {
        return scene.childNode(name: GameNodes.placed, baseExtension: config.baseExtension)?.children ?? []
    }()
    
    // Characters currently in the scene
    lazy var currentCharacters: [CharacterBot] = {
        return Array(scene.entities.filter({ $0 is CharacterBot})) as? [CharacterBot] ?? []
    }()
    
    // This is NPC's spawned in the scene
    var characters: SKNode {
        return scene.childNode(name: GameNodes.characters, baseExtension: config.baseExtension) ?? .init()
    }
    
    // This is the main furniture reference for the scene
    var furnitureNode: SKNode {
        return scene.childNode(name: GameNodes.furniture, baseExtension: config.baseExtension) ?? .init()
    }
    
    // The interacting zones which sit next to scene items
    lazy var zones: [SKNode] = {
        return scene.children.filter({$0.name?.contains("Zone") == true})
    }()
    
    // Used for tracking generated queues in a scene
    static var queuingBots: Set<QueueManagement> = []
    
    let scene: LevelScene
    
    var selectedNode: SKNode?
    var selectedNodeLastPosition: CGPoint?
}
