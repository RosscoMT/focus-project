//
//  LevelScene.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit
import Engine

/// LevelScene is an SKScene representing the playable level in the game.
class LevelScene: BaseScene, RendererSpriteKitScene {
    

    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    typealias config = GameplayConfiguration.Level
    typealias controlsConfig = GameplayConfiguration.GeneralControls
    
    // Global node for level
    var worldNode: SKNode {
        return childNode(name: GameNodes.world) ?? .init()
    }
    
    // Returns all obstacles which would determine pathway
    var scenesObstacles: [SKNode] {
        return [model.furniture, model.wall].reduce([], +)
    }
    
    // Data model for scene nodes
    lazy var model: LevelSceneModel = .init(scene: self)
    
    // Levels state machines controls what state the level maybe in
    lazy var stateMachine: ExtendedStateMachine = ExtendedStateMachine(states: [
        LevelScenePlayingState(levelScene: self),
        LevelScenePauseState(levelScene: self),
        LevelSceneSettingMenuState(levelScene: self),
        LevelSceneEditorState(levelScene: self),
        LevelSceneHelpState(levelScene: self),
        LevelSceneFurnitureStoreState(levelScene: self),
        LevelSceneAddState(levelScene: self)
    ])
    
    // Load menus from the ControlsScene.sks
    lazy var appMenu: GameMenus = GameMenus.loadNode(scene: "GameOptionsMenu", node: GameNodes.appMenuButton)
    lazy var menuBar: GameMenus = GameMenus.loadNode(scene: "ControlsScene", node: GameNodes.menuBar)
    
    // The initial point where the cursor is pressed
    var lastPosition: CGPoint = .zero
    var initialPanLocation: CGPoint = .zero
    
    var levelConfiguration: LevelConfiguration!
    var physicContacts: Set<CharacterPhysics> = []
    var selectedItem: Furniture?
    
    // Debug variable
    let playerBot: PlayerBot = PlayerBot()
    
    // Checks the last known spawed npc
    var npcSpawnTimeStamp: TimeInterval = 0
    
    // Checks if game is in play state
    var isplaying: Bool {
        return stateMachine.currentState is LevelScenePlayingState ? true : false
    }
    
    var timer: Timer?
    
    // -----------------------------------------------------------------
    // MARK: - Scene Life Cycle
    // -----------------------------------------------------------------
    
    func setupSKScene(with manager: SceneManager) {
        
        do {
            
            // Load the level's configuration from the level data file.
            levelConfiguration = try LevelConfiguration(fileName: sceneManager.currentSceneMetadata?.fileName)
            
            setupScene()
            
            // Add the app and menu bar to the camera node
            self.camera?.addChilds([appMenu, menuBar])
            
            // Cache the initial bar size
            menuBar.cachedMenuBarSize = menuBar.size
            
            // Setup the menu bars scale
            updateMenuBar()
            updateMenuPositions()
            
            // Setup the controls for the game level
            setupControls()
            
            // Setup debug
            setupDebug()
            
            // Setup the cameras default settings
            setupCamera()
            
            // Cycles through all assets to assign key information
            processSceneAssets()
            
            // Add a PlayerBot for the player.
            loadPlayerInScene()
        } catch {
            fatalError()
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        //let player = playerBot.renderComponent.componentNode
        
        // A LevelScene needs to update its camera constraints to match the new aspect ratio of the window when the window size changes.
//        camera?.setCameraConstraints(data: .init(board: board, node: player, size: size),
//                                     config: .init(cameraEdgeBounds: GameplayConfiguration.Level.cameraEdgeBounds))
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - SKScene Processing
    // -----------------------------------------------------------------
    
    // Called before each frame is rendered.
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
   
        // Assign the lastUpdateTimeInterval initial value if nil
        if lastUpdateTimeInterval == nil {
            lastUpdateTimeInterval = currentTime
        }
        
        // Calculate the amount of time since update was last called.
        let delta: TimeInterval = currentTime - lastUpdateTimeInterval!
        lastUpdateTimeInterval = currentTime
        
        // Only execute the code if the scene is not paused, prevents components from continuing to process
        if worldNode.isPaused == false {
            
            // Update the level's state machine.
            stateMachine.update(deltaTime: delta)
            
            // Update entities 
            for entity in entities {
                entity.update(deltaTime: delta)
            }
            
            // Update the component systems
            agentComponentSystem.update(deltaTime: delta)
        }
    }
 
    override func didFinishUpdate() {
        super.didFinishUpdate()
        
        // Keep HUD up to date
        updateHUD()
        
        // Check if the playerBot has been added to this scene.
        if let playerBotNode: SKNode = playerBot.component(ofType: RenderComponent.self)?.spriteNode, playerBotNode.scene == self {
            
            // Update the PlayerBot's agent position to match its node position. This makes sure that the agent is in a valid location in the SpriteKit physics world at the start of its next update cycle.
            playerBot.updateAgentPositionToMatchNodePosition()
        }
    }
    
    override func didEvaluateActions() {
        super.didEvaluateActions()
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
    }
    
    override func didApplyConstraints() {
        super.didApplyConstraints()
    }
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    @objc override func pauseScene() {
        
        // Handle pause gameplay between debug and production environments
        SceneManager.executeDebugRequests(type: .enablePause) {
            stateMachine.enter(LevelScenePauseState.self)
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - Interactive Button Types
    // -----------------------------------------------------------------
    
    override func buttonTriggered(button: ButtonNode) {
        
        guard let buttonIdentifier: ButtonIdentifier = button.buttonIdentifier else {
            return
        }
        
        switch buttonIdentifier {
        case .resume, .saveSettings, .okButton, .addFurnitureShipButton:
            
            switch stateMachine.currentState {
            case is LevelSceneFurnitureStoreState:
                
                if let items = stateMachine.currentState as? LevelSceneFurnitureStoreState {
                    
                    stateMachine.enter(LevelSceneAddState.self)
                    
                    if let state = stateMachine.currentState as? LevelSceneAddState {
                        state.setupState(items: items.model.items)
                    }
                }
            default:
                return
            }
        case .gameMenu:
            stateMachine.enter(LevelSceneSettingMenuState.self)
        case .plus, .minus:
            if let state = stateMachine.currentState as? LevelSceneFurnitureStoreState {
                state.adjustFurnitureItem(button: button)
            }
        case .quitOverlay:
            
            // Restore the previous state, if stored
            if let previousState = stateMachine.previousState {
                stateMachine.enter(previousState)
            } else {
                stateMachine.enter(LevelScenePlayingState.self)
            }
        case .addFurnitureCancelButton:
            stateMachine.enter(LevelScenePlayingState.self)
        default:
            super.buttonTriggered(button: button)
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GameInputDelegate
    // -----------------------------------------------------------------
    
    override func updateGameControlInputSources(gameInput: GameInput) {
        super.updateGameControlInputSources(gameInput: gameInput)
        
        // Update the player's controlInputSources to delegate input to the playerBot's InputComponent.
        for controlInputSource in gameInput.controlInputSources {
            controlInputSource.delegate = playerBot.component(ofType: InputComponent.self)
        }
        
        #if os(iOS)
        // When a game controller is connected, hide the thumb stick nodes.
        touchControlInputNode.hideThumbStickNodes = gameInput.isGameControllerConnected
        #endif
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - ControlInputSourceGameStateDelegate Methods
    // -----------------------------------------------------------------
    
    override func controlInputDownEvent(_ event: GameEvent, type: ControlInputType) {
        
        #warning("1: Original implementation of controlInputDownEvent no longer works. As the SKView is no longer being used. Getting the location from where the user tapped returns wrong values.")
        
        // Cache the initial pan location
        self.initialPanLocation = event.data.location(in: self)
        
        // Finds the nodes at the location of the mouse event
        let nodes: [SKNode] = self.camera?.nodesAtEventLocation(event) ?? []
        
        // Only call interactWithMenus if the mouse location includes menu item
        if nodes.contains(menus: GameNodes.menus)  {
            self.interactWithMenus(array: nodes, input: .down)
        } else {
            
            // Check the state machine to see if the state is valid to move about the scene
            switch stateMachine.currentState {
            case is LevelScenePlayingState, is LevelSceneEditorState:
                
                if self.gameplayArea(location: event.data.location(in: self), avoid: [GameNodes.menuBar.handle()]) {
                    
                    // Move the camera to the location of the click
                    self.camera?.run(.move(to: event.data.location(in: self), duration: 0.3), withKey: "CameraPoint")
                }
            default:
                return
            }
        }
    }
    
    override func controlInputUpEvent(_ event: GameEvent, type: ControlInputType) {
        
        // Check the state appMenu
        if appMenu.isSelected {
            self.interactWithMenus(array: [appMenu], input: .up)
        }
        
        // Clear panning view lastPosition and outstanding actions
        self.lastPosition = .zero
        self.initialPanLocation = .zero
        
        // Check if current state is in editor mode and node is selected
        if stateMachine.currentState is LevelSceneEditorState {
            
            // Run the animation on the background thread
            Task {
                
                // A final reposition before finishing
                await repositionFurnitureNode(with: event)
                
                // Clear the selected node from the
                model.selectedNode?.entity?.component(ofType: BoundaryComponent.self)?.removeBoundryBox()
                model.selectedNode = nil
            }
        }
        
        if self.camera?.action(forKey: "CameraPoint") == nil {
            self.camera?.removeAllActions()
        }
    }
    
    override func controlInputDownLongPressEvent(_ event: GameEvent, _ input: GameInput.Action, type: ControlInputType) {
        
        // Process the interaction by the machine state
        switch stateMachine.currentState {
        case is LevelSceneEditorState where input == .down:
            sceneItemAtLocation(event: event)
        default:
            return
        }
    }
    
    // Handling user interaction through drag action
    override func controlInputDragged(with event: GameEvent, type: ControlInputType) {
             
        // Process the interaction by the machine state
        switch stateMachine.currentState {
        case is LevelScenePlayingState:
            
            if let currentState: LevelScenePlayingState = stateMachine.currentState as? LevelScenePlayingState {
                currentState.mouseDragged(event: event)
            }
        case is LevelSceneEditorState, is LevelSceneAddState:
            Task {
               await repositionFurnitureNode(with: event)
            }
        default:
            return
        }
    }
    
    // Handle the magnification gesture
    override func controlInputPinchGesture(_ gesture: NSMagnificationGestureRecognizer, type: ControlInputType) {
        
//        self.worldNode.magnifyScene(gesture,
//                                  config: ["minimumZoom" : controlsConfig.minimumZoom, "maximumZoom" : controlsConfig.maximumZoom, "zoomRate" : controlsConfig.zoomRate])
    }
    
    // Handle double tap event
    override func controlDoubleTapEvent(_ event: GameEvent) {
        
        switch stateMachine.currentState {
        case is LevelSceneAddState:
            if let currentState = stateMachine.currentState as? LevelSceneAddState {
                currentState.confirmPlacement()
            }
        default:
            return
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - ControlInputSourceGameStateDelegate
    // -----------------------------------------------------------------
    
    override func controlInputDidTogglePauseState(_ inputSource: GenericInputSourceDelegate) {
        
        // Move level machine to pause screen
        switch stateMachine.currentState {
        case is LevelScenePauseState:
            
            if let previousState = stateMachine.previousState {
                stateMachine.enter(previousState)
            } else {
                stateMachine.enter(LevelScenePlayingState.self)
            }
        default:
            stateMachine.enter(LevelScenePauseState.self)
        }
    }
    
    #if DEBUG
    override func controlInputToggleDebug(_ value: Character) {
        
        // Toggle the debug info based on
//        switch value {
//        case Character(GameplayConfiguration.Keyboard.Controls.togglePhysics.rawValue):
//            skRenderer?.showsPhysics.toggle()
//            UserDefaults.standard.set(skRenderer?.showsPhysics, forKey: "PhysicsDebugToggle")
//        case Character(GameplayConfiguration.Keyboard.Controls.toggleInfo.rawValue):
//            skRenderer?.showsNodeCount.toggle()
//            skRenderer?.showsDrawCount.toggle()
//        default:
//            return
//        }
    }
    #endif
}

extension LevelScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Game Sound
    // -----------------------------------------------------------------
    
    func startGameMusic() {
        
        // Process asset for playing
        SoundToolKit.playMusic(scene: self,
                               audioNode: TestLevelSound.backgroundAudio!,
                               config: .init(delay: config.backgroundMusicDelay,
                                             volume: config.initialVolume,
                                             volumeChangeDuration: config.initialVolumeActionDuration))
    }
}
