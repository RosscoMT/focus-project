//
//  ExtendedStateMachine.swift
//
//
//  Created by Ross Viviani on 15/03/2024.
//

import GameplayKit

/// Extended state machine which allows for holding reference to the previous state
open class ExtendedStateMachine: GKStateMachine {
    
    // Store reference to the previous state
    public var previousState: GKState.Type?
    
    @discardableResult
    open override func enter(_ stateClass: AnyClass) -> Bool {
        
        if let currentState = self.currentState {
            previousState = type(of: currentState)
        }
        
        return super.enter(stateClass)
    }
}
