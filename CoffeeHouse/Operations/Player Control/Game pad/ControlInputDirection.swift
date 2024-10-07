//
//  ControlInputDirection.swift
//  DemoBots
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import Engine

// ControlInputDirection is extended to allow animation attributes for this games menu
public extension ControlInputDirection {
  
    // Load correct action for the selected direction, else throw an error
    func invalidMenuSelection() throws -> SKAction {
        
        do {
            switch self {
            case .up:
                return try SKAction.loadAction(name: "InvalidFocusChange_Up")
            case .down:
                return try SKAction.loadAction(name: "InvalidFocusChange_Down")
            case .left:
                return try SKAction.loadAction(name: "InvalidFocusChange_Left")
            case .right:
                return try SKAction.loadAction(name: "InvalidFocusChange_Right")
            }
        } catch {
            throw error
        }
    }
}
