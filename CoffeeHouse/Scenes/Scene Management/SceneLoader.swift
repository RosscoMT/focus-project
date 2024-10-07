//
//  SceneLoader.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 22/11/2022.
//

import GameplayKit

// Holds all the information required for the game view
class SceneLoader {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    /// Lists all the states that the scene loader can be in
    lazy var stateMachine: GKStateMachine = {
        
        var states: [GKState] = [
            SLInitialState(sceneLoader: self),
            SLResourcesAvailableState(sceneLoader: self),
            SLPreparingResourcesState(sceneLoader: self),
            SLResourcesReadyState(sceneLoader: self)
        ]
        
        return GKStateMachine(states: states)
    }()
    
    // The meta data relating to the scene
    let sceneMetadata: SceneMetadata

    // The loaded scene
    var scene: BaseScene?

    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    init(sceneMetadata: SceneMetadata) {
        self.sceneMetadata = sceneMetadata
    
        // Enter the initial state
        stateMachine.enter(SLInitialState.self)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Scene operation
    // -----------------------------------------------------------------
    
    func loadSceneForPresenting() {
        
        // Ensures that the resources for a scene are downloaded and begins loading them into memory.
        switch stateMachine.currentState {
            case is SLResourcesReadyState:
                return
            case is SLResourcesAvailableState:
                stateMachine.enter(SLPreparingResourcesState.self)
            default:
                fatalError("Invalid `currentState`: \(stateMachine.currentState!).")
        }
    }
}

extension SceneLoader: Hashable, Equatable {
    
    static func == (lhs: SceneLoader, rhs: SceneLoader) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sceneMetadata)
    }
}
