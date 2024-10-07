//
//  GKAgent2D+Extension.swift
//  
//
//  Created by Ross Viviani on 10/12/2022.
//

import GameplayKit

public extension GKAgent2D {
    
    // Custom struct which contains the differences
    fileprivate struct LocationDifference {
        let width: Float
        let height: Float
        
        init(_ width: Float, _ height: Float) {
            self.width = width
            self.height = height
        }
    }
    
    func updatePositioning(xAxis: Float, yAxis: Float) {
        self.position = SIMD2<Float>(x: xAxis, y: yAxis)
    }
    
    func updateBehaviour(goals: [GKGoal], weights: [NSNumber]) {
        self.behavior = GKBehavior(goals: goals, andWeights: weights)
    }
    
    // -----------------------------------------------------------------
    // MARK: - Static Distance Methods
    // -----------------------------------------------------------------
    
    /// The direct distance between two agents in the scene.
    static func distanceToAgent(agent: GKAgent2D, otherAgent: GKAgent2D) -> Float {
        let difference: LocationDifference = GKAgent2D.pointsDifference(agent.position, otherAgent.position)
        return hypot(difference.width, difference.height)
    }
    
    static func distanceToPoint(agent: GKAgent2D, otherPoint: SIMD2<Float>) -> Float {
        let difference: LocationDifference = GKAgent2D.pointsDifference(agent.position, .init(x: otherPoint.x, y: otherPoint.y))
        return hypot(difference.width, difference.height)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Static Private Methods
    // -----------------------------------------------------------------

    /// Returns the x and y positions difference between two agents
    static fileprivate func pointsDifference(_ a: vector_float2, _ b: vector_float2) -> LocationDifference {
        return .init(a.x - b.x, a.y - b.y)
    }
}
