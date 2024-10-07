//
//  IntelligenceComponent.swift
//  Coffee House
//
//  Created by Ross Viviani on 12/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A GKComponent that provides a GKStateMachine for entities to use in determining their actions.
class IntelligenceComponent: GKComponent {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    let stateMachine: GKStateMachine
    
    let initialStateClass: AnyClass
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    init(states: [GKState]) {
        stateMachine = GKStateMachine(states: states)
        initialStateClass = type(of: states.first!)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKComponent Life Cycle
    // -----------------------------------------------------------------
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        stateMachine.update(deltaTime: seconds)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Actions
    // -----------------------------------------------------------------
    
    func enterInitialState() {
        stateMachine.enter(initialStateClass)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
