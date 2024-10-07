//
//  SLResourcesReadyState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit

/// A state used by SceneLoader to indicate that all of the resources for the scene are loaded into memory and ready for use. This is the final state in the SceneLoader's state machine.
class SLResourcesReadyState: SLBaseState {
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Log the state
        self.logCurrentState(state: .resourceReady, scene: sceneLoader.sceneMetadata.fileName)
        
        // Notify to any interested objects that the download has completed.
        if self.sceneLoader.sceneMetadata.required {
            NotificationCenter.default.post(name: .requiredSceneLoaderDidComplete,
                                            object: nil)
        } else {
            NotificationCenter.default.post(name: .sceneLoaderDidComplete,
                                            object: nil,
                                            userInfo: ["sceneLoader" : sceneLoader])
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
            case is SLResourcesAvailableState.Type, is SLInitialState.Type:
                return true
            default:
                return false
        }
    }
}
