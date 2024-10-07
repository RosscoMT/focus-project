//
//  GameErrors.swift
//  
//
//  Created by Ross Viviani on 12/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation

/// Game error handling used for all types of errors which may occur in the game
public enum GameErrors: Error, Equatable, Handle {
    case skActionFailed(String)
    case decodeFailed
    case downloadFailed(String)
    case sceneLoader(String)
    case sceneConfiguration
    case sceneFile
    case locateFile
    case pathFailed
    case noPathFound
    case badPathDestination
    case exitNotFound
    case nodeNotFound
    case spriteMissing
    case incorrectResourceName
    case missingResource
    
    public func handle() -> String {
        switch self {
        case .skActionFailed(let string):
            return ""
        case .decodeFailed:
            return ""
        case .downloadFailed(let string):
            return ""
        case .sceneLoader(let string):
            return ""
        case .sceneConfiguration:
            return ""
        case .sceneFile:
            return "Unable to load the SKNode"
        case .locateFile:
            return "Unable to load the SKNode"
        case .noPathFound:
            return "No path could be found"
        case .pathFailed:
            return ""
        case .badPathDestination:
            return ""
        case .exitNotFound:
            return ""
        case .nodeNotFound:
            return ""
        case .spriteMissing:
            return ""
        case .incorrectResourceName:
            return ""
        case .missingResource:
            return ""
        }
    }
}
