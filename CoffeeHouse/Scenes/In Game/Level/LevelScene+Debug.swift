//
//  LevelScene+Debug.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 12/06/2023.
//

import SpriteKit
import Engine
import GameplayKit

extension LevelScene {
    
    typealias debug = GameplayConfiguration.Debug
    
    
    // -----------------------------------------------------------------
    // MARK: - Developer methods
    // -----------------------------------------------------------------
    
    /// Allows for focusing of the camera
    func focusCamera(sprite: SKNode?, point: CGPoint) {
        
        if sprite == nil {
            camera?.position = point
        } else {
            // Constrain the camera to the PlayerBot position
            camera?.setCameraConstraints(data: .init(board: model.board, node: sprite!, size: size),
                                         config: .init(cameraEdgeBounds: GameplayConfiguration.Level.cameraEdgeBounds))
        }
    }
    
    /// Allows for quick clearing of the scene
    func flushScene(sprite: SKNode) {
        
        // Stop spawning characters
        timer?.invalidate()
        
        // Remove all other characters from the scene
        let customerNodes: [SKNode] = children.filter({$0.entity is CharacterBot}).filter({$0 != sprite})
        let entities: [FoundationEntity] = customerNodes.map { $0.entity as! FoundationEntity }
        
        // Display debug information
        SceneManager.executeDebugRequests(type: .showPath, task: {
            entities.forEach({DebugTools.clearDebugNode(name: GKEntity.debugNodes(entity: $0), scene: self)})
        })
        
        // Remove from scene and reference
        customerNodes.forEach({$0.removeFromParent()})
        entities.forEach({self.entities.remove($0)})
    }
    
    /// Add mark to scene to allow for path discovery
    func markScene(a: CGPoint, b: CGPoint) {
        
        // THE CURRENT ISSUE IS THE DESTINATION IS LANDING IN THE MIDDLE OF A TABLE AND CURRENTLY IS GETTING TRAPPED IN AN ENDLESS LOOP OF NO PATH'S AVAILABLE
        DebugTools.markScene(a: a, b: b, scene: self, zPosition: WorldLayerPositioning.furniture.rawValue)
    }
    
    // -----------------------------------------------------------------
    // MARK: - Simulating methods
    // -----------------------------------------------------------------
    
    @objc func spawnCustomer() {
        
        // Use customer default spawn location initial position
        guard let spawnLocation: SKNode = childNode(name: GameNodes.customerSpawnLocation, path: ["characters"], baseExtension: config.baseExtension), stateMachine.currentState is LevelScenePlayingState else {
            return
        }
        
        // Initialise and setup components
        let customerBot = CharacterBot()
        customerBot.delegate = self
        customerBot.setupComponents(scene: self)
  
        // Add the node
        addEntity(entity: customerBot, layer: model.characters, zLayer: .characters)
        
        customerBot.componentNode.position = spawnLocation.position
        customerBot.agentComponent.agent.position = spawnLocation.position.vectorFloatPoint()
        
        // Load the entering of the scene
        customerBot.component(ofType: AgentComponent.self)?.enterSceneMandate()
        
        // If the entity has an IntelligenceComponent, enter its initial state.
        if let intelligenceComponent: IntelligenceComponent = customerBot.component(ofType: IntelligenceComponent.self) {
            intelligenceComponent.enterInitialState()
        }
        
//        camera?.setCameraConstraints(data: .init(board: model.board, node: customerBot.componentNode, size: size),
//                                     config: .init(cameraEdgeBounds: GameplayConfiguration.Level.cameraEdgeBounds))
        
        menuBar.updateMenuBar(data: .init(node: .customerNumber, info: model.characters.children.count))
        
        // Reduce counter
        debug.spawnCounter -= 1
        
        // Stop spawning if counter has hit zero
        if debug.spawnCounter == .zero {
            timer?.invalidate()
        }
    }
    
    /// Run a simulation of the scene
    @objc func simulateScene() {
        spawnCustomer()
    }
}
