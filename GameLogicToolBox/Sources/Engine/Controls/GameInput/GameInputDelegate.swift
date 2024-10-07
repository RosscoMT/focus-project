//
//  GameInputDelegate.swift
//  
//
//  Created by Ross Viviani on 22/11/2023.
//

import Foundation

public protocol GameInputDelegate: AnyObject {
    func updateGameControlInputSources(gameInput: GameInput)
}
