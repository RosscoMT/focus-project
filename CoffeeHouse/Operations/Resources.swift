//
//  Resources.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 27/04/2023.
//

import Foundation
import Engine

/// Resources are the files which are used within the game
enum Resources: String {
    
    case furnitureTypes
    case sceneConfiguration
    case levelBackgroundMusic = "cafeGameBackgroundMusic"
    
    func resourcesURL() -> URL? {
    
        switch self {
        case .furnitureTypes, .sceneConfiguration:
            return Bundle.main.url(forResource: self.rawValue.captializeString(), withExtension: "plist")
        case .levelBackgroundMusic:
            return Bundle.main.url(forResource: self.rawValue, withExtension: "wav")
        }
    }
}
