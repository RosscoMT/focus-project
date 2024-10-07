//
//  LevelSceneHelpState.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit

class LevelSceneHelpState: LevelSceneOverlayBaseState {

    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------

    override var overlaySceneFileName: GameResources {
        return .helpScene
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        levelScene.worldNode.isPaused = true
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        levelScene.worldNode.isPaused = false
    }
}
