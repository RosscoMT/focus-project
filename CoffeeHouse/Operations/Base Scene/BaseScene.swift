//
//  BaseScene.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 26/10/2022.
//

import SpriteKit
import GameplayKit
import Engine

// The base class is used for all scenes in the game. It includes methods, variables and functions which are commonly used.
class BaseScene: FoundationScene, GameInputDelegate, ControlInputSourceGameStateDelegate, ButtonNodeResponderType {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    lazy var agentComponentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    
    typealias configuration = GameplayConfiguration.Keyboard
    typealias debugSettings = GameplayConfiguration.Debug
    
    // All buttons currently in the scene
    lazy var buttons: [ButtonNode] = {
        return self.children.filter({$0.name?.localizedCaseInsensitiveContains("button") == true}) as? [ButtonNode] ?? []
    }()
    
    // The current scene overlay (if any) that is displayed over this scene.
    var overlay: SceneOverlay? {
        
        didSet {
            
            if let overlay: SceneOverlay = overlay {
                
                // Animate the overlay in.
                overlay.backgroundNode.run(SKAction.fadeIn(withDuration: 0.25))
                overlay.updateScale()
            }
            
            // Fades out the overlay opposed to removing it
            oldValue?.backgroundNode.run(SKAction.fadeOut(withDuration: 0.25))
        }
    }
    
    // Selected menu item
    var selectedMenuItem: ButtonNode?
    
    // Add obstacle graph for the pathfinding
    lazy var graph: GKObstacleGraph = GKObstacleGraph(obstacles: [], bufferRadius: 65)
    lazy var entities: Set<GKEntity> = Set<GKEntity>()
    lazy var graphs: [String : GKGraph] = [String : GKGraph]()
    
    // Holds references to all sprite nodes which require lighting
    var lightingArray: [Any] = []
    
    // Long press timing 
    var longPressTimer: Timer?
    var longPressCounter: TimeInterval = .zero
    
    // A reference to the scene manager for scene progression.
    weak var sceneManager: SceneManager!
    weak var sceneDelegate: SceneDelegate?
    
    // Gesture recognisers
    #if os(macOS)
    var magnificationGestureRecognizer: NSMagnificationGestureRecognizer?
    var mouseDownTimeStamp: Date?
    var doubleTapCount: [Date] = []
    #endif
    
    var lastUpdateTimeInterval: TimeInterval?
    var updateCameraPositions: Int = 0
    var cameraActions: [SKAction] = []
    
    // -----------------------------------------------------------------
    // MARK: - SKScene Life Cycle
    // -----------------------------------------------------------------
    
    func setupSKScene() {
        
        #if os(macOS)
        magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(pinchGesture))
        Renderer.metalView?.addGestureRecognizer(magnificationGestureRecognizer!)
        #endif
        
        setCamerasAttributes()
        updateCameraScale()
        overlay?.updateScale()
        
        // Listen for updates to the player's controls.
        sceneManager.gameInput.delegate = self
        isPaused = false
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        updateCameraScale()
        overlay?.updateScale()
    }
    
    // -----------------------------------------------------------------
    // MARK: - ButtonNodeResponderType
    // -----------------------------------------------------------------
    
    func buttonTriggered(button: ButtonNode) {
        
        // Encapsulates all buttons
        guard let buttonIdentifier: ButtonIdentifier = button.buttonIdentifier else {
            return
        }
        
        switch buttonIdentifier {
            
        // Main menu
        case .newGame:
            sceneManager.transitionToScene(identifier: .gameLevel(0))
        case .optionGame:
            sceneManager.transitionToScene(identifier: .options)
        case .loadGame:
            sceneManager.transitionToScene(identifier: .loadGame)
        
        // Options
        case .saveSettingsButton:
            sceneManager.transitionToScene(identifier: .mainMenu)
        case .cancelSettingsButton:
            sceneManager.transitionToScene(identifier: .mainMenu)
            
        // Options
        case .loadSelectGameButton:
            sceneManager.transitionToScene(identifier: .mainMenu)
        case .cancelLoadGameButton:
            sceneManager.transitionToScene(identifier: .mainMenu)
            
        case .quit:
            sceneManager.transitionToScene(identifier: .mainMenu)
            
        default:
            fatalError("Unsupported ButtonNode type in Scene.")
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - Camera Methods
    // -----------------------------------------------------------------
    
    func setCamerasAttributes() {
        self.camera?.zPosition = WorldLayerPositioning.camera.rawValue
    }
    
    // -----------------------------------------------------------------
    // MARK: - GameInputDelegate
    // -----------------------------------------------------------------
    
    func updateGameControlInputSources(gameInput: GameInput) {
        
        // Ensure all player controlInputSources delegate game actions to `BaseScene`.
        for source in gameInput.controlInputSources {
            source.gameStateDelegate = self
        }
        
        #if os(iOS)
        
        // On iOS, show or hide touch controls and focus based navigation when game controllers are connected or disconnected.
        touchControlInputNode.hideThumbStickNodes = sceneManager.gameInput.isGameControllerConnected
        #endif
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - ControlInputSourceGameStateDelegate
    // -----------------------------------------------------------------
    
    func controlInputDidSelect(_ inputSource: GenericInputSourceDelegate) {
        
        if let button = selectedMenuItem {
            buttonTriggered(button: button)
        }
    }
    
    func controlInput(_ inputSource: GenericInputSourceDelegate, didSpecifyDirection direction: ControlInputDirection) {
        
        // Handle vertical directional keys
        if direction == .down || direction == .up {
            
            switch self {
            case is MainMenuScene:
                highlightButton(direction: direction)
            default:
                return
            }
        }
        
        #if os(iOS)
        // On iOS, ensure that a game controller is connected otherwise ignore.
        guard sceneManager.gameInput.isGameControllerConnected else {
            return
        }
        #endif
    }
    
    func controlInputDidTogglePauseState(_ inputSource: GenericInputSourceDelegate) {
        // Subclasses implement to toggle pause state.
    }
    
    #if os(macOS)
    
    func controlInputUpEvent(_ event: GameEvent, type: ControlInputType) {
        // This will be subclassed
    }
    
    func controlInputDownEvent(_ event: GameEvent, type: ControlInputType) {
        // This will be subclassed
    }
    
    func controlInputDownLongPressEvent(_ event: GameEvent, _ input: GameInput.Action, type: ControlInputType) {
        // This will be subclassed
    }
    
    func controlInputDragged(with event: GameEvent, type: ControlInputType) {
        // This will be subclassed
    }
    
    func controlInputPinchGesture(_ gesture: NSMagnificationGestureRecognizer, type: ControlInputType) {
        // This will be subclassed
    }
    
    func controlDoubleTapEvent(_ event: GameEvent) {
        // This will be subclassed
    }
    
    #endif
    
    #if DEBUG
    func controlInputToggleDebug(_ value: Character) {
        // Subclasses implement if necessary, to display useful debug info.
    }
    #endif
}


extension BaseScene {
    
    
    // Allow for cycling through the menu items using direction keys. Animation is executed through the buttons own class.
    func highlightButton(direction: ControlInputDirection) {
        
        let menuButtons: [ButtonNode] = self.buttons
        
        // If no menu item is selected, select the first
        guard let currentButton: ButtonNode = menuButtons.first(where: {$0.isSelected}) else {
            
            let initialButton: ButtonNode? = menuButtons.first
            initialButton?.isSelected = true
    
            return
        }
        
        // Find the next button, else wrap to beginning or end
        if let currentSelectedIndex: Int = menuButtons.firstIndex(where: {$0 == currentButton}) {
            
            var nextIndex: Int?
            
            switch direction {
            case .up:
                if let index: Int = menuButtons.index(currentSelectedIndex, offsetBy: -1, limitedBy: 0) {
                    nextIndex = index
                } else {
                    nextIndex = menuButtons.endIndex - 1
                }
            case .down:
  
                if let index: Int = menuButtons.index(currentSelectedIndex, offsetBy: 1, limitedBy: menuButtons.endIndex - 1) {
                    nextIndex = index
                } else {
                    nextIndex = 0
                }
            default:
                return
            }
            
            menuButtons[nextIndex ?? 0].isSelected = true
        }
        
        // Reset the currently selected button
        currentButton.isSelected = false
    }
}
