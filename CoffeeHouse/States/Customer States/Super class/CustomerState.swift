//
//  CustomerState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 03/01/2023.
//

import Foundation
import GameplayKit
import Engine

/// Customer super class used for holding state logic for the various customer states
class CustomerState: GKState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    var renderComponent: RenderComponent {
        
        guard let renderComponent: RenderComponent = entity.component(ofType: RenderComponent.self) else {
            fatalError("A CharacterBot must have an RenderComponent.")
        }
        
        return renderComponent
    }
    
    var animationComponent: AnimationComponent<AnimationState> {
        
        guard let animationComponent: AnimationComponent<AnimationState> = entity.component(ofType: AnimationComponent.self) else {
            fatalError("A CharacterBot entity must have an AnimationComponent.")
        }
        
        return animationComponent
    }
    
    var orientationComponent: OrientationComponent {
        
        guard let orientationComponent: OrientationComponent = entity.component(ofType: OrientationComponent.self) else {
            fatalError("A CharacterBot entity must have an OrientationComponent.")
        }
        
        return orientationComponent
    }
    
    var agentComponent: AgentComponent {
        
        guard let agentComponent: AgentComponent = entity.component(ofType: AgentComponent.self) else {
            fatalError("A CharacterBot entity must have an OrientationComponent.")
        }
        
        return agentComponent
    }
    
    // Components used for tracking state
    var elapsedTime: TimeInterval = 0.0
    var timeSinceBehaviorUpdate: TimeInterval = 0.0
    
    
    unowned var entity: CharacterBot
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    required init(entity: CharacterBot) {
        self.entity = entity
    }
    
    func logDebug(info: String) {
        SceneManager.executeDebugRequests(type: .enableStateLog) {
            print(info)
        }
    }
}
