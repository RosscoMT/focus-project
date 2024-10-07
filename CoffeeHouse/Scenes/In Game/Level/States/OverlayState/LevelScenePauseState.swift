//
//  LevelScenePauseState.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit

class LevelScenePauseState: LevelSceneOverlayBaseState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    override var overlaySceneFileName: GameResources {
        return .pauseScene
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Pause the global node for scene and added nodes
        levelScene.worldNode.isPaused = true
        levelScene.timer?.invalidate()
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Release the global node and restart spawn timer
        levelScene.worldNode.isPaused = false
        levelScene.simulateScene()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }
}
