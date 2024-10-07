//
//  LevelSceneHelpState.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit
import Engine

class LevelScenePlayingState: GKState {
    

    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    unowned let levelScene: LevelScene
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    init(levelScene: LevelScene) {
        self.levelScene = levelScene
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Interaction
    // -----------------------------------------------------------------
    
    func mouseDragged(event: GameEvent) {
    #warning("This component needs to be rewritten to support the new metal setup")
//        guard levelScene.gameplayArea(location: levelScene.initialPanLocation, avoid: ["AppMenuButton", "ToggleInteraction", "MenuBar"]) else {
//            return
//        }
        
        // Calculate and generate moveBy action
        levelScene.worldNode.run(DragControls.panScene(lastPosition: &levelScene.lastPosition,
                                                     currentLocation: event.data.location(in: levelScene),
                                                     speed: GameplayConfiguration.GeneralControls.panningSpeed))
    }
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        print("NOW IN PLAYING MODE")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }
}
