//
//  LevelSceneSettingMenuState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 18/11/2022.
//

import GameplayKit

/// The game settings state for displaying options that can change the game
class LevelSceneSettingMenuState: LevelSceneOverlayBaseState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    override var overlaySceneFileName: GameResources {
        return .gameMenuScene
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    // Gameplay will be paused
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        levelScene.worldNode.isPaused = true
    }
    
    // Gameplay will remain paused until the view is resumed
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        levelScene.worldNode.isPaused = false
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }
}
