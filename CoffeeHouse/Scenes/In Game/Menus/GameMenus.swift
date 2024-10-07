//
//  GameMenus.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 18/11/2022.
//

import SpriteKit

final class GameMenus: SKSpriteNode {
    
    struct UpdateDataModel {
        let node: GameNodes
        let info: Any
    }
    
    // -----------------------------------------------------------------
    // MARK: - Type Alias
    // -----------------------------------------------------------------
    
    typealias configuration = GameplayConfiguration.InGameMenu
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    var isSelected: Bool = false
    var cachedMenuBarSize: CGSize = .zero
    
    // -----------------------------------------------------------------
    // MARK: - Unique Assets
    // -----------------------------------------------------------------
    
    lazy var tapImageTexture = {
        return SKTexture(imageNamed: "tap")
    }()
    
    lazy var swipeImageTexture = {
        return SKTexture(imageNamed: "swipe")
    }()
    
    
    // -----------------------------------------------------------------
    // MARK: - Animations
    // -----------------------------------------------------------------
    
    func animateDownButton() async {
        let increaseScale = SKAction.scale(by: 0.9,
                                           duration: configuration.animationDuration)
        
        await self.run(increaseScale)
    }
    
    func animateUpButton() async {
        let decreaseScale = SKAction.scale(by: 1.1,
                                           duration: configuration.animationDuration)
        
        await self.run(decreaseScale)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    func toggleInteraction() async {
        
        // Toggle the state
        isSelected.toggle()
        
        // Set the correct texture
        let selectedTexture: SKTexture = isSelected ? swipeImageTexture : tapImageTexture
        
        // Create sequence of animations
        let actions: SKAction = SKAction.sequence([.fadeOut(withDuration: configuration.menuFadeDuraction),
                                                   .setTexture(selectedTexture),
                                                   .fadeIn(withDuration: configuration.menuFadeDuraction)])
      
        // Use concurrency to guarantee execution without affecting performance
        await self.run(actions)
    }
    
    // -----------------------------------------------------------------
    // MARK: - Update menu bar
    // -----------------------------------------------------------------
    
    func updateMenuBar(data: UpdateDataModel) {
        
        if let node: SKLabelNode = childNode(withName: data.node.handle()) as? SKLabelNode {
            node.text = "\(data.info)"
        }
    }
}
