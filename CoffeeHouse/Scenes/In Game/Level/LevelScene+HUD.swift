//
//  LevelScene+HUD.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 02/04/2023.
//

import GameplayKit
import Engine


// The metal view and scene are the same size

extension LevelScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - HUD Display
    // -----------------------------------------------------------------
    
    func updateHUD() {
        
        // Only scale if views size has changed
        if Double(round(1000 * menuBar.xScale) / 1000) != Double(round(1000 * size.width / menuBar.cachedMenuBarSize.width) / 1000) {
            updateMenuPositions()
            updateMenuBar()
        }
    }
    
    func updateMenuPositions() {
        
        // Update the HUD if the screen has changed
        guard let camera: SKCameraNode = self.camera else {
            return
        }
        
        // Keep the position up to date
        appMenu.position = self.convert(.init(x: viewLeft + config.appMenuMargine, y: viewTop - config.appMenuMargine), to: camera)
        menuBar.position = self.convert(.init(x: viewLeft, y: viewBottom), to: camera)
    }
    
    func updateMenuBar() {
        menuBar.setScale(size.width / menuBar.cachedMenuBarSize.width)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Menu Interaction
    // -----------------------------------------------------------------
    
    func interactWithMenus(array: [SKNode], input: GameInput.Action) {
        
        // Check state is LevelScenePlayingState
        guard stateMachine.currentState is LevelScenePlayingState || stateMachine.currentState is LevelSceneEditorState || stateMachine.currentState is LevelSceneFurnitureStoreState, let menuItem: (menu: GameNodes, node: SKNode) = array.selectedMenu(menus: GameNodes.menus), let node: GameMenus = menuItem.node as? GameMenus else {
            return
        }
        
        switch menuItem.menu {
                
                // App menu button is spring loaded between input down and input up
            case .appMenuButton:
                
                Task {
                    
                    switch input {
                    case .down:
                        
                        node.isSelected = true
                        
                        await node.animateDownButton()
                        
                        stateMachine.enter(LevelSceneSettingMenuState.self)
                    case .up:
                        
                        node.isSelected = false
                        
                        await node.animateUpButton()
                    }
                }
                
                // The toggle for playing style only responses to the mouse down event
            case .toggleInteraction where input == .down:
                
                Task {
                    
                    // Toggle appearance based on the current state
                    await node.toggleInteraction()
                    
                    // Toggle the state machine pending if the user is in playing mode or editing
                    if node.isSelected {
                        stateMachine.enter(LevelSceneEditorState.self)
                    } else {
                        stateMachine.enter(LevelScenePlayingState.self)
                    }
                    
                    // Clear any cached node references for a furniture item when moving between machine states
                    selectedItem = nil
                    
                    // Update the physics and input behaviour for the player
                    playerBot.updateMachineState(stateMachine.currentState)
                }
            case .help:
                stateMachine.enter(LevelSceneHelpState.self)
            case .addFurniture:
                stateMachine.enter(LevelSceneFurnitureStoreState.self)
            default:
                return
        }
    }
}
