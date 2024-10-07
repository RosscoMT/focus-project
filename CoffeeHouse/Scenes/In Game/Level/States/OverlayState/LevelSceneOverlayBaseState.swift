//
//  LevelSceneOverlayBaseState.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit
import Engine

class LevelSceneOverlayBaseState: GKState {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    unowned let levelScene: LevelScene

    // The `SceneOverlay` to display when the state is entered.
    var overlay: SceneOverlay!
    
    // Overridden by subclasses to provide the name of the .sks file to load to show as an overlay.
    var overlaySceneFileName: GameResources {
        fatalError("Unimplemented overlaySceneName")
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    init(levelScene: LevelScene) {
        self.levelScene = levelScene
        
        super.init()
        
        do {
            self.overlay = try SceneOverlay(fileName: overlaySceneFileName,
                                            zPosition: WorldLayerPositioning.camera)
            levelScene.camera?.addChild(self.overlay.backgroundNode)
        } catch {
            fatalError()
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
     
        // Provide the levelScene with a reference to the overlay node.
        levelScene.overlay = overlay
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.overlay = nil
    }
}
