//
//  SceneLoaderBase.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//

import GameplayKit

/// The base class for SceneLoader States
class SLBaseState: GKState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    unowned var sceneLoader: SceneLoader
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    init(sceneLoader: SceneLoader) {
        self.sceneLoader = sceneLoader
    }
}
