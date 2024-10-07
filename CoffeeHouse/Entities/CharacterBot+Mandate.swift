//
//  CharacterBot+Mandate.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 24/05/2023.
//

import SpriteKit
import GameplayKit
import Engine

extension CharacterBot {
    
    
    // -----------------------------------------------------------------
    // MARK: - Mandate cycle check
    // -----------------------------------------------------------------
    
    /// Check the current nodes position
    static func enterScene(agentComponent: AgentComponent, nodePosition: CGPoint) -> Bool {
        
        // Check the current sprite position relative to the end of the path
        guard let agentsPosition = agentComponent.currentTargetPosition?.point() else {
            return false
        }
      
        // Calculate the distance between the two points
        switch agentComponent.pathOrientation {
        case .horizontal:
            
            return Geometry.calculatedDistance(valueOne: nodePosition.x,
                                               valueTwo: agentsPosition.x,
                                                 distance: 5)
        case .verticle:
            
            return Geometry.calculatedDistance(valueOne: nodePosition.y,
                                                 valueTwo: agentsPosition.y,
                                                 distance: 5)
        default:
            return false
        }
    }
    
    /// Leave mandate - for NPC's moving to leave the scene
    func leave(destination: SKNode) {
        
        // Detect if the character node has arrived at its destination
        guard let sceneComponent = component(ofType: SceneComponent.self) else {
            return
        }
        
        // Cancel all current behaviours
        agentComponent.stopCurrentBehaviour()
        
        // Display debug information
        SceneManager.executeDebugRequests(type: .showPath, task: {
            DebugTools.clearDebugNode(name: GKEntity.debugNodes(entity: self), scene: componentNode.scene)
        })
        
        do {
            
            // Run exit scene actions
            try sceneComponent.exitScene(exit: destination, sprite: componentNode) { [weak self] in
                self?.componentNode.removeFromParent()
                self?.delegate?.removeEntity(entity: self!)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
