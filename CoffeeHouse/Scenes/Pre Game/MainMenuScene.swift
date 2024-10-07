//
//  MainMenuScene.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 26/10/2022.
//

import SpriteKit

class MainMenuScene: BaseScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------

    // Returns the background node from the scene.
    override var backgroundNode: SKSpriteNode {
        return childNode(name: GameNodes.backgroundNode) as! SKSpriteNode
    }
    
    var newGameButton: ButtonNode {
        return backgroundNode.buttonNode(name: .newGame) as! ButtonNode
    }
    
    var loadGameButton: ButtonNode {
        return backgroundNode.buttonNode(name: .loadGame) as! ButtonNode
    }
    
    var optionGameButton: ButtonNode {
        return backgroundNode.buttonNode(name: .optionGame) as! ButtonNode
    }

    
    // -----------------------------------------------------------------
    // MARK: - Scene Life Cycle
    // -----------------------------------------------------------------

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Enable all main menu buttons
        buttons.forEach({$0.isUserInteractionEnabled = true})
        
        // Select initial menu option
        buttons.first?.isSelected = true
        
        // Position the camera to the background
        centerCameraOnPoint(point: backgroundNode.position)
    }
}
