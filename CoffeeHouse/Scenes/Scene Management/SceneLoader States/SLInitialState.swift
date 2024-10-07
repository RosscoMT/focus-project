//
//  SLInitialState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//

import GameplayKit

/// The initial state of a SceneLoader. Determines which state should be entered at the beginning of the scene loading process.
class SLInitialState: SLBaseState {
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Log the state
        self.logCurrentState(state: .initial, scene: sceneLoader.sceneMetadata.fileName)
  
        // On MacOS the resources will always be in local storage available for download.
        stateMachine!.enter(SLResourcesAvailableState.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SLResourcesAvailableState.Type
    }
}
