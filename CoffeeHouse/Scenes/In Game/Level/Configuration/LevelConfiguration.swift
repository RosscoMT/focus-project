//
//  LevelScene.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation
import Engine

// Encapsulates the starting configuration of a level in the game.
struct LevelConfiguration {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // Cached data loaded from the level's data file.
    private let configurationInfo: ConfigurationInfo
    
    // The initial orientation of the `PlayerBot` when the level is first loaded.
    let initialPlayerBotOrientation: CompassDirection

    // The file name identifier for this level. Used for loading files and assets.
    let fileName: String?
    
    // The factor used to normalize distances between characters for 'fuzzy' logic.
    var furnitureLibrary: Set<ShoppingItem<FurnitureType>> {
        return configurationInfo.furnitureLibrary
    }
    
    // The factor used to normalize distances between characters for 'fuzzy' logic.
    var startingBalance: Double {
        return configurationInfo.startingBalance
    }
    
    // The navigational paths used within the project
    var navigationGraphPaths: [NavigationGraphPaths] {
        return configurationInfo.navigationGraphPaths
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------

    init(fileName: String?) throws {
        self.fileName = fileName
        
        guard let url: URL = Bundle.main.url(forResource: fileName, withExtension: "plist") else {
            throw GameErrors.locateFile
        }
        
        do {
            
            // Decode the plist data from the URL
            self.configurationInfo = try Data.decodePlistData(url: url)

            self.initialPlayerBotOrientation = configurationInfo.initialPlayerBotOrientation
        } catch {
            throw error
        }
    }
}
