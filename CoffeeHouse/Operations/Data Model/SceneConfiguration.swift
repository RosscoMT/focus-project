//
//  SceneConfiguration.swift
//  DemoBots (iOS)
//
//  Created by Ross Viviani on 22/08/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import Engine

public struct SceneConfig: Decodable {
    
    enum CodingKeys: CodingKey {
        case fileName
        case sceneType
        case required
        case loadableTypes
    }
    
    enum Resources: String, Decodable {
        case customer
    }
    
    enum SceneType: String, Decodable {
        case intro = "IntroScene"
        case mainMenu = "MainMenuScene"
        case options = "OptionsScene"
        case loadGameScene = "LoadGameScene"
        case progress = "ProgressScene"
        case gameLevel = "GameLevelScene"
        case gameMenu = "GameMenuScene"
        case postGame = "PostGameScene"
    }
    
    let fileName: String
    let sceneType: SceneType
    let required: Bool
    let loadableTypes: [ResourceLoadableType.Type]?
    
    public init(from decoder: Decoder) throws {
        let decode = try decoder.container(keyedBy: CodingKeys.self)
        self.fileName = try decode.decode(String.self, forKey: .fileName)
        self.sceneType = try decode.decode(SceneType.self, forKey: .sceneType)
        self.required = try decode.decode(Bool.self, forKey: .required)
        
        // Directly convert class names into their class ResourceLoadableType types
        if let classNames: [String] = try decode.decodeIfPresent([String].self, forKey: .loadableTypes) {
            
            // Run through class names
            let array: [ResourceLoadableType.Type] = try classNames.map({
                
                // Lookup each class and pull ResourceLoadableType reference - Bundle.ClassName
                guard let bundle: String = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String, let classItem = NSClassFromString("\(bundle).\($0)") as? ResourceLoadableType.Type else {
                    throw GameErrors.incorrectResourceName
                }
                    
                return classItem
            })
            self.loadableTypes = array
        } else {
            self.loadableTypes = []
        }
    }
}
