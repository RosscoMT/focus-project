//
//  AnimationState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 26/12/2022.
//

import Foundation

/// The different animation states that are used across the game
enum AnimationState: String, Hashable {
    case idle = "Idle"
    case walkForward = "WalkForward"
    case walkBackward = "WalkBackward"
    case sit = "Sit"
    case sitDown = "SitDown"
    case takeItem = "TakeItem"
}
