//
//  Goals.swift
//  
//
//  Created by Ross Viviani on 20/04/2023.
//

import GameplayKit

public struct Goals: Hashable {
    
    /// Quick reference names for goals
    public enum Name: String {
        case toSeekAgent
        case toFleeAgent
        case toAvoid
        case toSeparateFrom
        case toAlignWith
        case toCohereWith
        case toReachTargetSpeed
        case toWander
        case toInterceptAgent
        case toFollow
        case toStayOn
        case stop
    }
    
    public let name: Name
    public let goal: GKGoal
    public let weight: NSNumber
    
    public init(name: Name, goal: GKGoal, weight: NSNumber) {
        self.name = name
        self.goal = goal
        self.weight = weight
    }
}
