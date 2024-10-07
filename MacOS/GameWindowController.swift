//
//  GameWindowController.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 08/10/2022.
//

import AppKit
import Engine

class GameWindowController: NSWindowController, NSWindowDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    var view: GameMetalView {
        let gameViewController: GameViewController = window!.contentViewController as! GameViewController
        return gameViewController.view as! GameMetalView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        window?.delegate = self
    }
    
    private func levelScene(value: Bool) {
        
        if let levelScene: LevelScene = Renderer.scene as? LevelScene, levelScene.stateMachine.currentState is LevelScenePlayingState {
            levelScene.worldNode.isPaused = value
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - NSWindowDelegate
    // -----------------------------------------------------------------
    
    func windowWillStartLiveResize(_ notification: Notification) {
        
        // Pause the scene while the window resizes if the game is active.
        levelScene(value: true)
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        
        levelScene(value: false)
    }
    
    /// When the window is no longer active view
    func windowDidResignMain(_ notification: Notification) {
        
        // Pause the scene when the window is no longer active
        //levelScene(value: true)
    }
    
    /// When the window is the active view
    func windowDidBecomeMain(_ notification: Notification) {
        
        // Un-pause the scene when the window stops resizing if the game is active.
        //levelScene(value: false)
    }
    
    // OS X games that use a single window for the entire game should quit when that window is closed.
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
