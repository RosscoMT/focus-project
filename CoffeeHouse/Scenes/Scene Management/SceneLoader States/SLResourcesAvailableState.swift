//
//  SLResourcesAvailableState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//

import GameplayKit

/// A state used by SceneLoader to indicate that all of the resources for the scene are available.
class SLResourcesAvailableState: SLBaseState {
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Log the state
        self.logCurrentState(state: .resourceAvailable, scene: sceneLoader.sceneMetadata.fileName)
        
        // Force load of listed scenes
        if sceneLoader.sceneMetadata.required {
            stateMachine?.enter(SLPreparingResourcesState.self)
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
            case is SLInitialState.Type, is SLPreparingResourcesState.Type:
                return true
            default:
                return false
        }
    }
    
}
