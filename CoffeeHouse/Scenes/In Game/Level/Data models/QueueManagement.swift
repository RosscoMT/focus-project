//
//  QueueManagement.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 04/10/2023.
//

import Foundation
import GameplayKit
import Engine

/// Used for managing the queuing bots in the game level
struct QueueManagement: Hashable {
    let node: SKNode
    var pathArray: [QueueSlot] = []
    var queuedEntities: [CharacterBot] = []
}

class QueueSlot: SKShapeNode {
    let destination: SKNode
    
    init(destination: SKNode, rect: CGRect) {
        self.destination = destination
        super.init()
        self.path = CGPath.init(rect: rect, transform: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QueueManagement {
    
    // Creates a queue line for bots based on the best possible options
    init(destination: SKNode, character: CharacterBot) {
        
        guard let scene: LevelScene = destination.scene as? LevelScene else {
            fatalError("Only LevelScene scenes can be used with this method")
        }
        
        // Round the frames origins to allow for easier analysis
        let initialFrame: CGRect = destination.frameWithRoundedOrigin()
        let size: CGSize = destination.frame.size
        
        // Obstacles we want to avoid
        var sceneObstacles = [scene.model.furniture + scene.model.wall + scene.model.zones].reduce([], +)
        sceneObstacles.remove(at: sceneObstacles.firstIndex(of: destination)!)
        
        // Convenience func to generate each path
        func direction(value: Direction) -> [QueueSlot] {
            
            var places: [QueueSlot] = []
            
            // Build an array of objects we won't to detect
            let obstacles: [CGRect] = sceneObstacles.map({$0.frameWithRoundedOrigin()})
            
            // Starting from 0, stride forward by the size of the initial destination to form a queue
            for _ in stride(from: 0, to: scene.frame.width, by: size.width) {
                
                let nodePosition: CGPoint
                let colour: NSColor
                
                switch value {
                case .down:
                    nodePosition = .init(x: initialFrame.origin.x, 
                                         y: initialFrame.minY - (CGFloat(places.count) * size.height))
                    colour = .systemMint
                case .up:
                    nodePosition = .init(x: initialFrame.origin.x, 
                                         y: initialFrame.minY + (CGFloat(places.count) * size.height))
                    colour = .systemIndigo
                case .left:
                    nodePosition = .init(x: initialFrame.origin.x - (CGFloat(places.count) * size.width), 
                                         y: initialFrame.minY)
                    colour = .systemGreen
                case .right:
                    nodePosition = .init(x: initialFrame.origin.x + (CGFloat(places.count) * size.width), 
                                         y: initialFrame.minY)
                    colour = .systemOrange
                }
                
                // Setup the queue node
                let queue = QueueSlot(destination: destination, rect: .init(origin: .zero, size: size))
                queue.position = nodePosition
                
                // Stop the loop if the current proposed queue position hits the wall
                if obstacles.contains(where: {$0.intersects(.init(origin: nodePosition, size: size))}) {
                    break
                }
                
                // Display the proposed queue positions
                SceneManager.executeDebugRequests(type: .displayPlottedQueue) {
                    queue.lineWidth = 0
                    queue.fillColor = colour
                    scene.addChild(queue)
                }
                
                places.append(queue)
            }
            
            return places
        }
        
        node = destination
        pathArray = [direction(value: .left), direction(value: .right), direction(value: .up), direction(value: .down)].sorted(by: {$0.count > $1.count}).first ?? []
        queuedEntities.append(character)
    }
}

extension Set where Element == QueueManagement {
    
    /// Issue arises from trying to replace the queue object with an updated version
    mutating func replace(_ queue: QueueManagement) {
        
        if let firstItem = self.first(where: {$0.node == queue.node}) {
            self.remove(firstItem)
            self.insert(queue)
        }
    }
}

extension QueueManagement {
    
    /// Returns the next available position, while also adding the new entity
    mutating func nextPosition(entity: CharacterBot) -> SKNode? {
        
        // A) You have no nodes in array
        // B) You have already nodes within array
        // C) Nodes array is filled
        
        // Based on the current queue count
        switch queuedEntities.count {
        case 0 where pathArray.count != 0:
            self.queuedEntities.append(entity)
            return pathArray[0]
        default:

            if let lastNode: CharacterBot = queuedEntities.last, let index: Int = queuedEntities.lastIndex(of: lastNode) {
                
                defer {
                    self.queuedEntities.append(entity)
                }
                
                // Return only available queue slots
                if index + 1 < pathArray.count {
                    return pathArray[index + 1]
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    /// Move forward the other bots in the queue
    mutating func moveForward() -> [SKAction] {
        
        // Remove the bot to the front of the queue
        queuedEntities.removeFirst()
        
        // Check if the queue is empty
        guard queuedEntities.isEmpty == false else {
            return []
        }
        
        var actionsContainer: [SKAction] = []
         
        for index in 0..<queuedEntities.count {
            actionsContainer.append(SKAction.sequence([.move(to: pathArray[index].centrePoint(), duration: 0.5), .wait(forDuration: 0.2)]))
        }
        
        return actionsContainer
    }
    
    static func removeEntity(entity: CharacterBot) {
        
        if var queue = LevelSceneModel.queuingBots.first(where: {$0.queuedEntities.contains(entity)}), let index: Int = queue.queuedEntities.firstIndex(where: {$0 == entity}) {
            queue.queuedEntities.remove(at: index)
            LevelSceneModel.queuingBots.replace(queue)
        }
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.vectorFloatPoint())
    }
}

