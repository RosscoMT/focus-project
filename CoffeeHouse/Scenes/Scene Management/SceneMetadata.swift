//
//  SceneMetadata.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation
import Engine

// Encapsulates the metadata about a scene in the game.
struct SceneMetadata {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // The Game scene sks file name
    let fileName: String
    
    // Game scene controller
    let sceneType: BaseScene.Type
    
    // The list of types with resources that should be preloaded for this scene.
    let loadableTypes: [ResourceLoadableType.Type]
    
    // Indicates if the scene requires to be loaded during initialisation
    let required: Bool
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    // Initializes a new `SceneMetadata` instance from a dictionary.
    init(sceneConfiguration: SceneConfig) {
        
        fileName = sceneConfiguration.fileName
        
        // Assign the scene type
        switch sceneConfiguration.sceneType {
            case .intro:
                sceneType = IntroScene.self
            case .mainMenu:
                sceneType = MainMenuScene.self
            case .options:
                sceneType = OptionScene.self
            case .progress:
                sceneType = ProgressScene.self
            case .loadGameScene:
                sceneType = LoadGameScene.self
            case .gameLevel:
                sceneType = LevelScene.self
            case .gameMenu:
                sceneType = GameMenuScene.self
            case .postGame:
                sceneType = CreditsScene.self
        }
        
        var loadableTypesForScene: [ResourceLoadableType.Type] = [ResourceLoadableType.Type]()
        loadableTypesForScene.append(contentsOf: sceneConfiguration.loadableTypes ?? [])
        
        // Set up the `loadableTypes` to be prepared when the scene is requested.
        loadableTypes = loadableTypesForScene
        required = sceneConfiguration.required
    }
}


// -----------------------------------------------------------------
// MARK: - Hashable
// -----------------------------------------------------------------

// Extend `SceneMetadata` to conform to the `Hashable` protocol so that it may be used as a dictionary key by `SceneManger`.
extension SceneMetadata: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileName.hashValue)
    }
}

extension SceneMetadata: Equatable {
    
    // In order to be `Hashable`, `SceneMetadata` must also be `Equatable`. This requirement is satisfied by providing an equality operator function that takes two `SceneMetadata` instances and determines if they are equal.
    static func ==(lhs: SceneMetadata, rhs: SceneMetadata)-> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
