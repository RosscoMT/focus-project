//
//  CustomerMandate.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 29/05/2023.
//

import SpriteKit
import Engine

// Actions the customer
indirect enum CustomerMandate: Equatable, CustomDebugStringConvertible {
    
    typealias Settings = GameplayConfiguration.Level.NPC
    
    enum NavigationMandates {
        case walkTo
        case queue(queueInfo: AdvanceInTimeByModel)
        case served(secs: Double)
        case leave
    }
    
    case enterScene // Character enters scene
    case walkTo(destination: SKNode) // Customer freely moving around
    case queue(destination: SKNode, queueInfo: AdvanceInTimeByModel) //
    case served(destination: SKNode, secs: Double, timeStamp: TimeInterval?) // Customer is being served by another npc
    case stand
    case consumeSitting(secs: Double, timeStamp: TimeInterval) // Customer is either consuming or sitting idly
    case consumeStanding // Customer is either consuming or sitting idly
    case wander(retry: CustomerMandate?, timeStamp: TimeInterval, wait: Double)
    case leave(destination: SKNode)
    case none
    
    var debugDescription: String {
        switch self {
        case .enterScene:
            return "Enter Scene"
        case .walkTo:
            return "WalkTo"
        case .queue:
            return "Queue"
        case .served:
            return "Served"
        case .stand:
            return "Stand"
        case .consumeSitting:
            return "Consume Sitting"
        case .consumeStanding:
            return "Consume Standing"
        case .wander:
            return "Wander"
        case .leave:
            return "Leave"
        case .none:
            return "None"
        }
    }
    
    // Used for generating the queue information the NPC
    static func queueInfo() -> AdvanceInTimeByModel {
        
        // Use either the development or production queue times 
        if SceneManager.gameBuild == .development {
            return .init(seconds: GeneralTools.randomNumberInRange(lowest: Settings.devLowestQueueTime,
                                                                   highest: Settings.devHighestQueueTime))
        } else {
            return .init(seconds: GeneralTools.randomNumberInRange(lowest: Settings.lowestQueueTime,
                                                                   highest: Settings.highestQueueTime))
        }
    }
    
    // Combines the new destination and mandate specific information into a customer mandate
    static func updateMandate(_ destination: SKNode, mandate: NavigationMandates) -> CustomerMandate {
        
        switch mandate {
        case .walkTo:
            return .walkTo(destination: destination)
        case .queue(let queueInfo):
            return .queue(destination: destination, queueInfo: queueInfo)
        case .served(let secs):
            return .served(destination: destination, secs: secs, timeStamp: nil)
        case .leave:
            return .leave(destination: destination)
        }
    }
}
