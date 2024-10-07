//
//  RulesComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 14/08/2023.
//

import GameplayKit
import Engine

class RulesComponent: GKComponent {
    
    var agentComponent: AgentComponent {
        
        guard let agentComponent: AgentComponent = entity?.component(ofType: AgentComponent.self) else {
            fatalError("A CharacterBot missing agent component.")
        }
        
        return agentComponent
    }
    
    // Rule system used for the component
    let ruleSystem: GKRuleSystem = .init()
    
    // Efficiency switch to control rules execution
    var suspendUpdate: Bool = false

    // Quick access
    lazy var botEntity: CharacterBot = entity as! CharacterBot
    
    /// Re-evaluate the current rule state
    func updateState(deltaTime seconds: TimeInterval) {

        guard suspendUpdate == false else {
            return
        }
        
        switch botEntity.currentMandate {
        case .enterScene:
             
            // Evaluate the current nodes positioning before updating
            if ruleSystem.evaluate(state: ["agentComponent" : agentComponent, "position" : componentNode.position], rules: [Rules.enterScene()]) == .proceed {
                
                // Attempt to assign the bots location, configure behaviour and begin execution of
                seekCounter()
            }
        case .queue(destination: let destination, queueInfo: let value):
 
            // Evaulate the rules to check arrivedAtDestination and findDestination
            guard ruleSystem.evaluate(state: ["destinationPoint" : destination.centrePoint(), "nodePosition" : botEntity.componentNode.position, "characterBot" : botEntity, "nodePath" : FurnitureType.collectionArea, "verifyAvailability" : false], rules: [Rules.arrivedAtDestination(), Rules.findDestination()]) == .proceed else {
                
                // If the bot has been trapped, we use the physics contact detection to alert us
                if let bot = botEntity.level.physicContacts.first(where: {$0.entity == botEntity}), ruleSystem.evaluate(state: ["timeStamp" : bot.timestamp, "time" : 1.0], rules: [Rules.timeHasElapsed()]) == .proceed {
                    
                    // Abort the current attempt
                    abortAttempt(node: destination, queueInfo: value)
                }
                
                return
            }
            
            // Stop the bots current behaviour and move to the centre of the pad
            stopBot(destination: destination)

            // Timestamp that the bot has arrived at the destination
            guard value.timestamp != nil else {
                botEntity.currentMandate = .queue(destination: destination, queueInfo: .init(seconds: value.seconds, timestamp: currentTimeStamp()))
                return
            }
            
            // Check if the count down
            guard ruleSystem.evaluate(state: ["time" : value.seconds, "timeStamp" : value.timestamp!], rules: [Rules.timeHasElapsed()]) == .proceed else {
                return
            }
    
            // Check the bots position within the queue array
            if ruleSystem.evaluate(state: ["bot" : botEntity], rules: [Rules.firstInQueue()]) == .proceed {
                  
                updateCurrentQueue()
                
                // Build the next rule for the bot
                navigateToLocation(node: .collectionArea, mandate: .served(secs: 3))
            }
        case .served(destination: let destination, secs: let seconds, timeStamp: let timeStamp):
            
            // Evaluate the rules to check arrivedAtDestination
            guard ruleSystem.evaluate(state: ["destinationPoint" : destination.centrePoint(), "nodePosition" : botEntity.componentNode.position], rules: [Rules.arrivedAtDestination()]) == .proceed else {
                return
            }
            
            // Stop the bots current behaviour and move to the centre of the pad
            stopBot(destination: destination)
        
            // Record time stamp when the character has arrived at the destination
            if timeStamp == nil {
                botEntity.currentMandate = .served(destination: destination, secs: seconds, timeStamp: currentTimeStamp())
                return
            }
            
            // Check if time has elapsed before before proceding
            guard ruleSystem.evaluate(state: ["time" : seconds, "timeStamp" : timeStamp!], rules: [Rules.timeHasElapsed()]) == .proceed else {
                return
            }
            
            // Build the next rule for the bot
            navigateToLocation(node: .table, mandate: .walkTo)
        case .walkTo(destination: let destination):
            
            guard ruleSystem.evaluate(state: ["destinationPoint" : destination.centrePoint(), "nodePosition" : botEntity.componentNode.position], rules: [Rules.arrivedAtDestination()]) == .proceed else {
                return
            }
            
            // Stop the bots current behaviour and move to the centre of the pad
            stopBot(destination: destination)
            
            // Assign mandate
            botEntity.currentMandate = .consumeSitting(secs: 5, timeStamp: currentTimeStamp())
        case .consumeSitting(let secs, let timeStamp):
            
            guard ruleSystem.evaluate(state: ["time" : secs, "timeStamp" : timeStamp], rules: [Rules.timeHasElapsed()]) == .proceed else {
                return
            }

            // Update mandate and assign behaviour
            navigateToLocation(node: .door, mandate: .leave)
        case .leave(destination: let destination):
            
            guard ruleSystem.evaluate(state: ["destinationPoint" : destination.centrePoint(), "nodePosition" : botEntity.componentNode.position], rules: [Rules.arrivedAtDestination()]) == .proceed else {
                return
            }
            
            botEntity.leave(destination: destination)
        case .wander(retry: let mandate, timeStamp: let timeStamp, wait: let secs):
            
            guard ruleSystem.evaluate(state: ["time" : secs, "timeStamp" : timeStamp], rules: [Rules.timeHasElapsed()]) == .proceed else {
                return
            }
            
            switch mandate {
            case .queue:
                
                // Because the bot is no longer part of any queues and has no path. It is easier to just hard reset it using the enterScene logic
                seekCounter()
            default:
                botEntity.currentMandate = mandate
            }
        default:
            return
        }
    }
    
    /// Stops the current characters agent and update the rotation
    func stopBot<T: SKNode>(destination: T?) {
        
        guard botEntity.agentComponent.isActive == true else {
            return
        }
        
        suspendUpdate = true
        
        agentComponent.stopCurrentBehaviour(false)
        
        Task {
            
            switch destination {
            case is PadSprite:
                
                if let padSprite = destination as? PadSprite {
                    
                    // Move node to centre position of pad
                    await self.componentNode.run(.group([textures(position: padSprite.parentNode!.position), .move(to: padSprite.centrePoint(), duration: 0.5)]))
                    
                    // Manually set the direction to face based on the destination
                    await updateRotation(position: padSprite.parentNode!.position)
                }
            case is QueueSlot:
                
                if let padSprite = destination as? QueueSlot {
 
                    // Move node to centre position of pad
                    await self.componentNode.run(.group([textures(position: padSprite.destination.position), .move(to: padSprite.centrePoint(), duration: 0.5)]))
                    
                    // Manually set the direction to face based on the destination
                    await updateRotation(position: padSprite.destination.position)
                }
            default:
                return
            }
            
            self.suspendUpdate = false
        }
    }
    
    /// Loads the relevant texture based on orientation, type and state
    private func textures(position: CGPoint) async -> SKAction {
        
        let destinationOrientation = await NodeNavigation.destinationAngle(valueOne: componentNode.position,
                                                                           valueTwo: position)
        
        let animation = botEntity.animationComponent.animation(type: .walkForward,
                                                               withDirection: CompassDirection(zRotation: destinationOrientation))
        
        return SKAction.animate(with: animation.textures, timePerFrame: AnimationConfig.timePerFrame)
    }
    
    /// Update state and rotation
    private func updateRotation(position: CGPoint) async {
        
        //Update the bots stateMachine
        self.botEntity.updateStateMachine(state: .idleState)
        
        // Manually set the direction to face based on the destination
        self.botEntity.orientationComponent.adjustRotation(position)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

struct Rules {
    
    /// Rules to test if the bot has arrived in the scene
    static func enterScene() -> GKRule {
        return .init { ruleSystem in
            
            guard let agent = ruleSystem.state["agentComponent"] as? AgentComponent, let position = ruleSystem.state["position"] as? CGPoint else {
                return false
            }
             
            return CharacterBot.enterScene(agentComponent: agent, nodePosition: position)
        } action: { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "enterScene").handle())
        }
    }
    
    /// Rule checks if there specified destination is available
    static func findDestination() -> GKRule {
        
        return .init { ruleSystem in
            
            // Unpack the ruleSystem state data
            guard let bot = ruleSystem.state["characterBot"] as? CharacterBot, let nodePath = ruleSystem.state["nodePath"] as? FurnitureType, let verifyAvailability = ruleSystem.state["verifyAvailability"] as? Bool else {
                return false
            }
            
            do {
                if try bot.mandateDestination(node: nodePath, verifyAvailability: verifyAvailability) != nil {
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        } action: { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "findDestination").handle())
        }
    }
    
    /// Rule checks if there specified destination is available
    static func pathwayDiscovered() -> GKRule {
        
        return .init { ruleSystem in
            
            // Unpack the ruleSystem state data
            guard let destination = ruleSystem.state["destination"] as? SKNode, let agent = ruleSystem.state["agent"] as? AgentComponent else {
                return false
            }
            
            do {
                return try agent.navigateMandate(destination: destination, debugPoints: false).isEmpty == false
            } catch {
                return false
            }
        } action: { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "pathwayDiscovered").handle())
        }
    }
    
    /// Rule to test if the animation is active
    static func animationActive() -> GKRule {
        return .init(blockPredicate: { ruleSystem in
           
            guard let entity = ruleSystem.state["characterBot"] as? CharacterBot, let animationKey = ruleSystem.state["animationKey"] as? String else {
                return false
            }
            
            return !entity.componentNode.animationActive(animationKey: animationKey)
        }) { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "animationActive").handle())
        }
    }
    
    /// Rule checks if the node has arrived at the destination
    static func arrivedAtDestination() -> GKRule {
        return .init(blockPredicate: { ruleSystem in
           
            guard let destinationPoint = ruleSystem.state["destinationPoint"] as? CGPoint, let currentPosition = ruleSystem.state["nodePosition"] as? CGPoint else {
                return false
            }
       
            return CGPoint.distance(from: currentPosition, to: destinationPoint) < 60
        }) { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "arrivedAtDestination").handle())
        }
    }
    
    /// Rule checks if set amount of time has elapsed
    static func timeHasElapsed() -> GKRule {
        return .init(blockPredicate: { ruleSystem in
            
            guard let time = ruleSystem.state["time"] as? Double, let timeStamp = ruleSystem.state["timeStamp"] as? TimeInterval else {
                return false
            }
            
            return GeneralTools.timeElapsed(timeStamp: timeStamp, wait: time)
        }) { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "timeHasElapsed").handle())
        }
    }
    
    /// Rule checks if there is any bots queuing
    static func destinationHasQueue() -> GKRule {
        return .init(blockPredicate: { ruleSystem in
            
            guard let node = ruleSystem.state["destination"] as? SKNode else {
                return false
            }
            
            return (LevelSceneModel.queuingBots.first(where: {$0.node == node}) != nil)
        }) { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "destinationHasQueue").handle())
        }
    }
    
    /// Rule checks if the bot is first in the queue
    static func firstInQueue() -> GKRule {
        return .init(blockPredicate: { ruleSystem in
            
            guard let botEntity = ruleSystem.state["bot"] as? CharacterBot, let queue: QueueManagement = LevelSceneModel.queuingBots.first(where: {$0.queuedEntities.first == botEntity}), let position = queue.queuedEntities.firstIndex(where: {$0 == botEntity}) else {
                return false
            }
 
            return position == 0
        }) { ruleSystem in
            ruleSystem.assertFact(RulesOutcome.passed(test: "firstInQueue").handle())
        }
    }
}
