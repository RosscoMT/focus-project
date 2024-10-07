//
//  GameInput.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameController

/// An abstraction representing game input for the user currently playing the game. Manages the player's control input sources, and handles game controller connections / disconnections.
public final class GameInput {
    
    // Input style enum
    public enum Action: String {
        case down
        case up
    }
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    #if os(tvOS)
    public var nativeControlInputSource: GenericInputSourceDelegate?
    #else
    public let nativeControlInputSource: GenericInputSourceDelegate
    #endif
    
    // An optional secondary input source for a connected game controller.
    private(set) var secondaryControlInputSource: GameControllerInputSource?
    
    public var isGameControllerConnected: Bool {
        var isGameControllerConnected: Bool = false
        
        DispatchQueue.main.async {
            isGameControllerConnected = (self.secondaryControlInputSource != nil) || (self.nativeControlInputSource is GameControllerInputSource)
        }
        
        return isGameControllerConnected
    }

    public var controlInputSources: [GenericInputSourceDelegate] {
        let sources: [GenericInputSourceDelegate?] = [nativeControlInputSource, secondaryControlInputSource]
        return sources.compactMap { $0 as GenericInputSourceDelegate? }
    }

    public weak var delegate: GameInputDelegate? {
        didSet {
            delegate?.updateGameControlInputSources(gameInput: self)
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------

    public init(nativeControlInputSource: GenericInputSourceDelegate) {
        self.nativeControlInputSource = nativeControlInputSource
        
        #warning("If the mac version of this game will support a game pad we will need logic setup")
        //setupGameControllerNotifications()
    }
    
    #if os(tvOS)
    public init() {
        
        // Search for paired game controllers.
        for pairedController in GCController.controllers() {
            update(withGameController: pairedController)
        }
        
        //registerForGameControllerNotifications()
    }
    #endif

    // Register for `GCGameController` pairing notifications.
    public func setupGameControllerNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameInput.handleControllerDidConnectNotification(notification:)),
                                               name: .GCControllerDidConnect,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameInput.handleControllerDidDisconnectNotification(notification:)),
                                               name: .GCControllerDidDisconnect,
                                               object: nil)
    }
    
    public func update(withGameController gameController: GCController) {
        
        DispatchQueue.main.async {
            #if os(tvOS)
            // Assign a controller to the `nativeControlInputSource` if one does not already exist.
            if self.nativeControlInputSource == nil {
                self.nativeControlInputSource = GameControllerInputSource(gameController: gameController)
                return
            }
            #endif
            
            // If not already assigned, add a game controller as the player's secondary control input source.
            if self.secondaryControlInputSource == nil {
                let gameControllerInputSource: GameControllerInputSource = GameControllerInputSource(gameController: gameController)
                self.secondaryControlInputSource = gameControllerInputSource
                gameController.playerIndex = .index1
            }
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GCGameController Notification Handling
    // -----------------------------------------------------------------
    
    @objc public func handleControllerDidConnectNotification(notification: NSNotification) {
        
        guard let connectedGameController: GCController = notification.object as? GCController else {
            return
        }
        
        update(withGameController: connectedGameController)
        delegate?.updateGameControlInputSources(gameInput: self)
    }
    
    @objc public func handleControllerDidDisconnectNotification(notification: NSNotification) {
        
        guard let disconnectedGameController: GCController = notification.object as? GCController else {
            return
        }
        
        // Check if the player was being controlled by the disconnected controller.
        if secondaryControlInputSource?.gameController == disconnectedGameController {
            
            DispatchQueue.main.sync {
                self.secondaryControlInputSource = nil
            }
            
            // Check for any other connected controllers.
            if let gameController: GCController = GCController.controllers().first {
                update(withGameController: gameController)
            }
            
            delegate?.updateGameControlInputSources(gameInput: self)
        }
    }
}
