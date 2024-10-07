//
//  LevelSceneEditorState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//

import GameplayKit
import Engine

/// State dedicated to when the game is in editor mode
class LevelSceneEditorState: GKState {
    

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
    
    func menuInteraction(_ event: GameEvent) {
        
        // Finds the nodes at the location of the mouse event
        let nodes: [SKNode] = levelScene.camera?.nodesAtEventLocation(event) ?? []
        
        // Only call interactWithMenus if the mouse location includes menu item
        if nodes.contains(menus: GameNodes.menus) {
            levelScene.interactWithMenus(array: nodes, input: .down)
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        print("NOW IN EDITOR MODE")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }
}
