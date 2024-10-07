//
//  Level+Setup.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 02/04/2023.
//

import SpriteKit
import GameplayKit
import Engine

extension LevelScene: LevelSceneSetupProtocol {
    
    
    // -----------------------------------------------------------------
    // MARK: - Level Construction
    // -----------------------------------------------------------------
    
    func setupScene() {
        
        // Setup the physics
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Set the state machine to its initial state
        stateMachine.enter(LevelScenePlayingState.self)
    }
    
    func setupCamera() {
        camera?.positionWithScale(position: .init(x: 0, y: 0), scale: 2.4)
    }
    
    func setupDebug() {
        
        SceneManager.executeDebugRequests(type: .enableAudio) {
            startGameMusic()
        }
        
        SceneManager.executeDebugRequests(type: .simulateScene) {
            
            // Initise the timer
            timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(simulateScene), userInfo: nil, repeats: true)
            
            // Delay the firing by x seconds
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2, execute: {
                self.timer?.fire()
            })
        }
    }
    
    func setupControls() {
        
        #if os(iOS)
        // Set up iOS touch controls. The player's nativeControlInputSource is added to the scene by the BaseSceneTouchEventForwarding extension.
        addTouchInputToScene()
        touchControlInputNode.hideThumbStickNodes = sceneManager.gameInput.isGameControllerConnected
        #endif
    }

    func addEntity<T: SKNode>(entity: GKEntity, layer: T, zLayer: WorldLayerPositioning) {
        
        entities.insert(entity)
        
        // Add sprite to scene
        if let node = entity.component(ofType: RenderComponent.self)?.spriteNode {
            layer.addChild(node)
        }
        
        // If the entity has an IntelligenceComponent, enter its initial state.
        if let intelligenceComponent: IntelligenceComponent = entity.component(ofType: IntelligenceComponent.self) {
            intelligenceComponent.enterInitialState()
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Player and NPC spawning methods
    // -----------------------------------------------------------------
    
    func loadPlayerInScene() {
         
        // Find the location of the player's initial position.
        guard let charactersNode: SKNode = childNode(name: GameNodes.characters, baseExtension: config.baseExtension), let spawnLocation: SKNode = charactersNode.childNode(name: GameNodes.playerSpawnLocation), debugSettings.enablePlayerSpawning else {
            return
        }
        
        // Set the initial orientation.
        guard let orientationComponent: OrientationComponent = playerBot.component(ofType: OrientationComponent.self) else {
            fatalError("A player bot must have an orientation component to be able to be added to a level")
        }
        
        orientationComponent.compassDirection = levelConfiguration.initialPlayerBotOrientation
        
        // Set up the PlayerBot position in the scene.
        let playerNode: SKNode = playerBot.renderComponent.spriteNode!
        playerNode.position = spawnLocation.position
        playerBot.updateAgentPositionToMatchNodePosition()
        
//        // Constrain the camera to the PlayerBot position
        camera?.setCameraConstraints(data: .init(board: model.board, node: playerNode, size: size),
                                     config: .init(cameraEdgeBounds: GameplayConfiguration.Level.cameraEdgeBounds))
        
        // Add the PlayerBot to the scene and component systems.
        addEntity(entity: playerBot, layer: model.characters, zLayer: .characters)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - SKScene methods
    // -----------------------------------------------------------------
    
    /// Configure the scenes assets with their correct information to ensure better performance when rendering
    func processSceneAssets() {
        
        let scenesAssets: [SKNode] = [model.furniture, model.wall, model.entryPoints].reduce([], +)
        
        // Process each node, detemining type then assigning correct z positioning data
        scenesAssets.forEach({ WorldLayerPositioning.sceneAssets(asset: FurnitureType.assetName(name: $0.name), node: $0)})
        
        menuBar.updateMenuBar(data: .init(node: .furnitureNumber, info: model.furniture.count))
    }
}
