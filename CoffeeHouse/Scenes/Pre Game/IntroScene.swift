//
//  IntroScene.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 26/10/2022.
//

import SpriteKit

class IntroScene: BaseScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // Returns the background node from the scene.
    override var backgroundNode: SKSpriteNode {
        return childNode(name: GameNodes.backgroundNode) as! SKSpriteNode
    }
    
    var introTile: SKLabelNode {
        return childNode(withName: "//IntroTitle") as! SKLabelNode
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Scene Life Cycle
    // -----------------------------------------------------------------
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Setup notifications
        centerCameraOnPoint(point: backgroundNode.position)
        
        // Hide and reposition the intro node
        introTile.alpha = 0
        introTile.position = .init(x: self.calculateAccumulatedFrame().midX, y: viewTop)
        
        // Add simple animation for the intro scene
        animateIntroScene()
    }
    
    func animateIntroScene() {
       
        let appear: SKAction = SKAction.run { [weak self] in
            self?.introTile.alpha = 1
        }
        
        let move: SKAction = SKAction.move(to: .init(x: self.calculateAccumulatedFrame().midX, y: self.calculateAccumulatedFrame().midY),
                                           duration: 2)
        
        let transition: SKAction = SKAction.run { [weak self] in
            self?.sceneDelegate?.transitionToScene(scene: .mainMenu, secondsDelay: 2.5)
        }
        
        introTile.run(SKAction.group([appear, move, transition]))
    }
}
