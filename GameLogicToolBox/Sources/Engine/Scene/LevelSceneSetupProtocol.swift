//
//  LevelSceneSetupProtocol.swift
//
//
//  Created by Ross Viviani on 01/04/2024.
//

import Foundation

/// Methods for setting up the core game level SKScene 
public protocol LevelSceneSetupProtocol {
    func setupScene()
    func setupCamera()
    func setupDebug()
}
