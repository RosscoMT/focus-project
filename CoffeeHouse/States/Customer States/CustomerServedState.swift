//
//  CustomerServedState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 02/01/2023.
//

import Foundation
import GameplayKit

class CustomerServedState: CustomerState {
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        logDebug(info: "State: Served")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // This a temporary animation till a final one is made
        animationComponent.requestedAnimationState = .idle
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}
