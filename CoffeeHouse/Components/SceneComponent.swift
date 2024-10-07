//
//  SceneComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 19/05/2023.
//

import GameplayKit
import SpriteKit
import Engine

/// Pad component allows for detecting of other sprites which have moved onto it
class SceneComponent: GKComponent {
    
    typealias ConfigScene = GameplayConfiguration.Level
    
    // Determine which side the exit is one
    private func direction(node: SKNode, board: SKNode, offsetBy: CGFloat) -> CGPoint {
        
        let left: CGPoint = .init(x: node.frame.minX - offsetBy, y: node.frame.midY)
        let right: CGPoint = .init(x: node.frame.maxX + offsetBy, y: node.frame.midY)
        let top: CGPoint = .init(x: node.frame.midX, y: node.frame.minY + offsetBy)
        let down: CGPoint = .init(x: node.frame.midX, y: node.frame.maxY - offsetBy)
        
        // Try and find which side the door sits
        if board.contains(left) {
            return right
        } else if board.contains(right) {
            return left
        } else if board.contains(top) {
            return down
        } else {
            return top
        }
    }
    
    // Exits a character from the scene by moving and fading them out
    func exitScene(exit: SKNode, sprite: SKNode, completion: @escaping () -> Void) throws {
         
        // Fetch all required nodes
        guard let scene = componentNode.scene, let board: SKNode = scene.childNode(name: GameNodes.board, baseExtension: GameplayConfiguration.Level.baseExtension)?.children.first else {
            throw GameErrors.nodeNotFound
        }
        
        // Try and determine which side the exit sits on
        let point = direction(node: exit, board: board, offsetBy: ConfigScene.exitMoveBy)
        
        // Group all the actions nodes in sequence
        let actionGroup = SKAction.group([.wait(forDuration: ConfigScene.exitWaitTime), 
                                          .move(to: point, duration: ConfigScene.exitMoveDuration),
                                          .fadeOut(withDuration: ConfigScene.exitFadoutTime)])
        
        // Run the actions with completion code
        sprite.run(actionGroup, completion: completion)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
