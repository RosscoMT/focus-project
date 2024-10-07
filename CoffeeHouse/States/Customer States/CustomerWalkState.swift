//
//  CustomerWalkState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 02/01/2023.
//

import Foundation
import GameplayKit

class CustomerWalkState: CustomerState {
  
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        logDebug(info: "State: WalkForward")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        animationComponent.requestedAnimationState = .walkForward
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
}
