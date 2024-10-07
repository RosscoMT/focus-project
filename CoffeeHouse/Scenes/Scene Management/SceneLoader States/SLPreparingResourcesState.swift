//
//  SLPreparingResourcesState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit
import Engine

/// A state used by SceneLoader to indicate that resources for the scene are being loaded into memory.
class SLPreparingResourcesState: SLBaseState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // Store the loaded resources
    var loadSceneOperation: LoadSceneOperation?
    
    var sceneMetadata: SceneMetadata {
        return sceneLoader.sceneMetadata
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Log the state
        self.logCurrentState(state: .preparingResource, scene: sceneLoader.sceneMetadata.fileName)
        
        // Begin loading the scene and associated resources
        Task(priority: .userInitiated) {
            
            // Check if there is any loadable resource
            if sceneMetadata.loadableTypes.isEmpty == true {
                
                // Create load scene operation
                loadSceneOperation = LoadSceneOperation(sceneMetadata: sceneMetadata)
            } else {
                
                // Compiling of the scenes resources
                loadSceneOperation = await loadResources()
            }
            
            await setupLoadedScene()
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is SLResourcesReadyState.Type:
            return true
        case is SLResourcesAvailableState.Type:
            return true
        default:
            return false
        }
    }
    
}

extension SLPreparingResourcesState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Load Resources Asynchronously
    // -----------------------------------------------------------------
    
    private func loadResources() async -> LoadSceneOperation {
        
        let loadSceneOperation: LoadSceneOperation = LoadSceneOperation(sceneMetadata: sceneMetadata)
        
        // If no resources need to be loaded, skip
        guard sceneMetadata.loadableTypes.isEmpty == false else {
            return loadSceneOperation
        }
        
        let resources: [LoadResources] = sceneMetadata.loadableTypes.compactMap({LoadResources(loadableType: $0)})
        
        // Track the loaded resources
        var index: Int = 0
        
        // For loops don't work well with async await
        while index < resources.count {
            let initialResources: LoadResources = resources[index]
            await initialResources.start()
            index += 1
            NotificationCenter.default.post(name: .sceneLoaderUpdate, object: nil)
        }
        
        return loadSceneOperation
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Post Loading Resources
    // -----------------------------------------------------------------
    
    @MainActor
    @objc private func setupLoadedScene() async {
        
        // Intialise the scenes GKScene file with assets
        let result: Result<BaseScene, GameErrors>? = self.loadSceneOperation?.initalizeScene()
        
        // Process the result
        switch result {
        case .success(let scene):
            
            // Copy over the loaded
            self.sceneLoader.scene = scene
            
            // Move state to ready
            let didEnterReadyState: Bool = self.stateMachine!.enter(SLResourcesReadyState.self)
            assert(didEnterReadyState, "Failed to transition to `ReadyState` after resources were prepared.")
        case .failure(let error):
            assertionFailure(error.handle())
        default:
            return
        }
    }
}
