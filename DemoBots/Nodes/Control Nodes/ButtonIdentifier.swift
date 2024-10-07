//
//  ButtonIdentifier.swift
//  DemoBots
//
//  Created by Ross Viviani on 10/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation

// The complete set of button identifiers supported in the app.
enum ButtonIdentifier: String, CaseIterable {
    
    // Main menu
    case newGame = "nameGameButton"
    case loadGame = "loadGameButton"
    case optionGame = "optionGameButton"
    
    // Options
    case saveSettingsButton
    case cancelSettingsButton
    
    // Load Game
    case loadSelectGameButton
    case cancelLoadGameButton
    
    // In-game Menu
    case resume = "Resume"
    case gameMenu = "Game Menu"
    case quit = "Quit"
    
    // Add items
    case plus = "Plus"
    case minus = "Minus"
    case addFurnitureShipButton = "AddFurnitureShipButton"
    case addFurnitureCancelButton = "AddFurnitureCancelButton"
    
    // Help menu
    case okButton = "OK"
    
    case saveSettings = "Save Settings"
    case quitOverlay = "Quit Overlay Button"
    
    // The name of the texture to use for a button when the button is selected.
    var selectedTextureName: String? {
        return nil
    }
    
    var identifer: String {
        return self.rawValue
    }
    
    static func focusPriority() -> [ButtonIdentifier] {
        return [
            .newGame,
            .loadGame,
            .optionGame,
            .saveSettingsButton,
            .cancelSettingsButton,
            .loadSelectGameButton,
            .cancelLoadGameButton,
            .resume,
            .gameMenu,
            .quit
        ]
    }
}
