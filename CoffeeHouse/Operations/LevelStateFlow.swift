//
//  LevelStateFlow.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 15/03/2024.
//

import GameplayKit

enum LevelStateControl: String {
    
    case pauseState = "LevelScenePauseState"
    case furnitureStoreState = "LevelSceneFurnitureStoreState"
    case helpState = "LevelSceneHelpState"
    case settingsState = "LevelSceneSettingMenuState"
    case editorState = "LevelSceneEditorState"
    case addState = "LevelSceneAddState"
    case playingState = "LevelScenePlayingState"
    
    // The allowed next states based on each state
    func allowedNextStates() -> [Self] {
        switch self {
        case .pauseState:
            return [.playingState, .settingsState, .furnitureStoreState, .addState]
        case .furnitureStoreState:
            return [.addState, .pauseState, .playingState, .settingsState]
        case .helpState:
            return [.playingState, .editorState]
        case .settingsState:
            return [.pauseState, .playingState, .editorState, .furnitureStoreState]
        case .editorState:
            return [.pauseState, .settingsState, .playingState, .helpState]
        case .addState:
            return [.playingState, .pauseState]
        case .playingState:
            return [.pauseState, .settingsState, .editorState, .helpState, .furnitureStoreState]
        }
    }
}

extension GKState {
    
    /// Checks the if the next state is valid
    /// - Parameter withClass: The requested next state
    /// - Returns: Boolean value indicating if the state can move to the next proposed state
    func nextState(withClass: AnyClass) -> Bool {
        
        // Pull the current state class name and the proposed next class name
        guard let currentStateName: String = className.components(separatedBy: ".").last, let nextState: String = withClass.debugDescription().components(separatedBy: ".").last else {
            return false
        }
        
        // Generate the enum value for the current state based on it own class name
        guard let state = LevelStateControl(rawValue: currentStateName) else {
            return false
        }

        return state.allowedNextStates().contains(where: {$0.rawValue == nextState})
    }
}
