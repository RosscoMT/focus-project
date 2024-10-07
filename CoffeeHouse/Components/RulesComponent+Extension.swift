//
//  RulesComponent+Extension.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 02/11/2023.
//

import SpriteKit
import Engine

extension RulesComponent {
    
    struct QueueInformation {
        let queuing: Bool
        let node: SKNode?
    }
    
    // -----------------------------------------------------------------
    // MARK: - Initial mandate logic
    // -----------------------------------------------------------------
    
    func seekCounter() {
        
        // Evaluate the destination is available
        guard let till: SKNode = try? botEntity.mandateDestination(node: .till, verifyAvailability: false), ruleSystem.evaluate(state: ["destination" : till, "agent" : agentComponent], rules: [Rules.pathwayDiscovered()]) == .proceed else {
            return
        }
        
        // Destination for the bot when they enter the scene
        let queueInfo: QueueInformation = queueDestination(sceneNode: till)
        
        // Based on the results set either the destination or new behaviour
        switch queueInfo.queuing {
        case true where queueInfo.node == nil:
            agentComponent.wander()
            botEntity.currentMandate = .wander(retry: .enterScene, timeStamp: currentTimeStamp(), wait: 10)
        default:
            
            // Generate the path to the queue based on the data we got back
            guard let node: SKNode = queueInfo.node, let behaviour = try? agentComponent.navigateMandate(destination: node, debugPoints: true) else {
                return
            }
            
            // Load next mandate
            botEntity.currentMandate = .queue(destination: node, queueInfo: CustomerMandate.queueInfo())
            
            // Update behaviours - Test this code out to see if the new goals are setup and able to run
            agentComponent.updateGoalsAndBehaviour(goals: behaviour)
        }
    }
    
    /// Try and navigate to the desired scene node
    func navigateToLocation(node: FurnitureType, mandate: CustomerMandate.NavigationMandates) {
        
        // Find node in scene, evaluate possible paths and build path
        if let newDestination: SKNode = try? botEntity.mandateDestination(node: node, verifyAvailability: false), ruleSystem.evaluate(state: ["destination" : newDestination, "agent" : agentComponent], rules: [Rules.pathwayDiscovered()]) == .proceed, let behaviour = try? agentComponent.navigateMandate(destination: newDestination, debugPoints: true) {
            
            // Load next mandate and behaviours
            updateMandateAndBehaviours(mandate: .updateMandate(newDestination, mandate: mandate),
                                       behaviour: behaviour)
        } else {
            
            // Use wander mandate to store the current mandate till
            botEntity.currentMandate = .wander(retry: botEntity.currentMandate, timeStamp: currentTimeStamp(), wait: 5)
            
            // Update behaviour
            agentComponent.wander()
        }
    }
    
    func updateMandateAndBehaviours(mandate: CustomerMandate, behaviour: [Goals]) {
        botEntity.currentMandate = mandate
        agentComponent.updateGoalsAndBehaviour(goals: behaviour)
    }
    
    private func queueDestination(sceneNode: SKNode) -> QueueInformation {
        
        // Based if there is a queue the bot will either start or join it
        if var queue = LevelSceneModel.queuingBots.first(where: {$0.node == sceneNode}) {
            
            // Check for a position in the queue
            if let nextQueueSpot: SKNode = queue.nextPosition(entity: botEntity) {
                
                // We replace the the current queue model
                LevelSceneModel.queuingBots.replace(queue)
                
                // Return the newly discovered queue destination
                return .init(queuing: true, node: nextQueueSpot)
            } else {
                
                // The queue has exceeded its available size
                return .init(queuing: true, node: nil)
            }
        } else {
            
            // Insert a new queue model for the destination
            LevelSceneModel.queuingBots.insert(.init(destination: sceneNode, character: botEntity))
            
            return .init(queuing: false, node: sceneNode)
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - Queue Management
    // -----------------------------------------------------------------
    
    func updateCurrentQueue() {
        
        // Suspend the rules component, this is to free up system processing, while
        self.suspendUpdate = true
        
        // Extract the queue management
        var queue: QueueManagement = LevelSceneModel.queuingBots.first(where: {$0.queuedEntities.first == botEntity})!
        
        // The next animations for the bots
        let actions = queue.moveForward()
        
        // Cycle through the queue updating the remaining
        for index in 0..<queue.queuedEntities.count {
            
            // Suspend the execution of the bot
            queue.queuedEntities[index].component(ofType: RulesComponent.self)?.suspendUpdate = true
            
            // Re-assign the destination due to the queue moving forward
            if case .queue(destination: _, queueInfo: let qInfo) = queue.queuedEntities[index].currentMandate {
                
                // Update the bots current mandate with the new destination
                queue.queuedEntities[index].currentMandate = .queue(destination: queue.pathArray[index], queueInfo: qInfo)
                
                // Check is the bot has joined the queue or simply walking to it
                if qInfo.timestamp != nil {
                    
                    // Run the animations to move forward and then allow execution of the component
                    queue.queuedEntities[index].componentNode.run(actions[index]) { [weak self] in
                        
                        // Prevent the new first in queue bot from moving to the next mandate immediately
                        if index == .zero {
                            
                            // Update the bots current mandate with the new destination
                            queue.queuedEntities[index].currentMandate = .queue(destination: queue.pathArray[index], queueInfo: .init(seconds: 5, timestamp: self?.currentTimeStamp()))
                        }
                        
                        queue.queuedEntities[index].component(ofType: RulesComponent.self)?.suspendUpdate = false
                    }
                } else {
                    
                    queue.queuedEntities[index].agentComponent.stopCurrentBehaviour()
                    
                    // Generate the a new path to the queue based on the new data
                    guard let behaviour = try? agentComponent.navigateMandate(destination: queue.pathArray[index], debugPoints: true) else {
                        return
                    }
                    
                    // Update behaviours - Test this code out to see if the new goals are setup and able to run
                    queue.queuedEntities[index].agentComponent.updateGoalsAndBehaviour(goals: behaviour)
                    queue.queuedEntities[index].component(ofType: RulesComponent.self)?.suspendUpdate = false
                }
            }
        }
        
        LevelSceneModel.queuingBots.replace(queue)
        
        // Suspend the rules component, this is to free up system processing, while
        self.suspendUpdate = false
    }
    
    func abortAttempt(node: SKNode, queueInfo: AdvanceInTimeByModel) {
        
        // Remove the bot from the queue
        QueueManagement.removeEntity(entity: botEntity)
        
        // Update the behaviour and mandate
        agentComponent.wander()
        botEntity.currentMandate = .wander(retry: .queue(destination: node, queueInfo: queueInfo), timeStamp: currentTimeStamp(), wait: 5)
    }
}
