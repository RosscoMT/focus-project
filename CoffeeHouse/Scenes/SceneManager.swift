//
//  SceneIdentifier.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 22/11/2022.
//

import SpriteKit
import Engine

protocol RendererSpriteKitScene {
    func setupSKScene(with manager: SceneManager)
}

protocol SceneManagerDelegate: AnyObject {
    func sceneManager(_ sceneManager: SceneManager, didTransitionTo scene: SKScene)
}

/// Protocol which handles interaction between the scene and scene manager
protocol SceneDelegate: AnyObject {
    func transitionToScene(scene: SceneIdentifier, secondsDelay: Double)
}

final class SceneManager {
    
    // The build of the game
    enum GameBuildType {
        case development
        case production
    }
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------

    public let gameInput: GameInput
    
    // Stor the current scene meta data
    private (set) var currentSceneMetadata: SceneMetadata?
    
    // Store the scene loaders
    private var sceneLoaders: Set<SceneLoader> = []
    
    // Scenes are requested for display, initial value will be the first to be displayed
    private var requestedScene: SceneIdentifier = {
        
        switch SceneManager.gameBuild {
        case .development:
            return GameplayConfiguration.Debug.scene
        default:
            return .intro
        }
    }()
    
    // All present scenes are cached for reference
    private var presentSceneLoader: SceneLoader?
    
    // Track the loaded required resources, during initialisation
    private var requiredScenesRemaining = 0 {
        didSet {
            
            if requiredScenesRemaining == 0 {
                transitionToScene(identifier: requestedScene)
            }
        }
    }
    
    // The release type of the game
    public static let gameBuild: GameBuildType = {
    #if DEBUG
        return .development
    #else
        return .production
    #endif
    }()
    
    weak var delegate: SceneManagerDelegate?
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------

    init(gameInput: GameInput) throws {
        
        self.gameInput = gameInput
        
        guard let url: URL = Resources.sceneConfiguration.resourcesURL() else {
            throw GameErrors.sceneConfiguration
        }
        
        do {
            
            // Decode the plist data from the URL
            let scenes: [SceneConfig] = try Data.decodePlistData(url: url)
            
            // To allow scalability set is used for speed and uniqueness
            let sceneConfigurationInfo: Set<SceneMetadata> = Set(scenes.map{SceneMetadata(sceneConfiguration: $0)})
            
            // Create a list of scene loaders
            sceneLoaders = Set(sceneConfigurationInfo.map({SceneLoader(sceneMetadata: $0)}))
            
            // Calculate total required scenes
            requiredScenesRemaining = sceneLoaders.filter({$0.sceneMetadata.required}).count
            
            // Setup notifications
            setupNotifications()
        } catch {
            throw error
        }
    }
}

extension SceneManager {
    
    
    // -----------------------------------------------------------------
    // MARK: - Scene Transitioning
    // -----------------------------------------------------------------
    
    func transitionToScene(identifier sceneIdentifier: SceneIdentifier) {
        
        // Pull loader from request scene identifier
        guard let sceneLoader: SceneLoader = self.sceneLoader(forSceneIdentifier: sceneIdentifier) else {
            return
        }
        
        // The scene is ready to be displayed.
        if sceneLoader.stateMachine.currentState is SLResourcesReadyState {
            presentScene(loader: sceneLoader)
        } else {
            
            // Cache the requested scene
            requestedScene = sceneIdentifier
            
            // Start the loading of the scenes resources
            sceneLoader.loadSceneForPresenting()
            
            // Display progress scene in the meantime
            presentProgressScene(loader: sceneLoader)
        }
    }
    
    /// Presents scene
    func presentScene(loader: SceneLoader) {
        
        // Extract the loaded scene
        guard let scene: BaseScene & RendererSpriteKitScene = loader.scene as? BaseScene & RendererSpriteKitScene else {
            return
        }
        
        // Hold on to a reference to the currently requested scene's metadata
        currentSceneMetadata = loader.sceneMetadata
        
        // Provide the scene with a reference to the `SceneLoadingManger` so that it can coordinate the next scene that should be loaded.
        scene.sceneManager = self
        
        // Add scene delegate
        scene.sceneDelegate = self
        
        scene.setupSKScene(with: self)
        
        // Present the scene with a transition.
        Renderer.presentScene(with: scene)
        
        // Notify the delegate that the manager has presented a scene.
        self.delegate?.sceneManager(self, didTransitionTo: scene)
    }
    
    // Configures the progress scene before presenting
    func presentProgressScene(loader: SceneLoader) {
        
        // Pull the progress scene loader
        if let sceneLoader = sceneLoader(forSceneIdentifier: .progress) {
            
            // Setup and present the progress scene
            if let scene = sceneLoader.scene as? ProgressScene {
                
                scene.update(progressTotal: loader.sceneMetadata.loadableTypes.compactMap({LoadResources(loadableType: $0)}).count)
                scene.setupSKScene(with: self)
                
                Renderer.presentScene(with: scene)
            }
        }
    }
}

extension SceneManager {
    
    
    // -----------------------------------------------------------------
    // MARK: - Notifications
    // -----------------------------------------------------------------
    
    /// Require resources are checked off as they load into memory
    @objc func requiredSceneLoaderDidComplete() {
        self.requiredScenesRemaining -= 1
    }
    
    /// Reources have been loaded for scene loader
    @objc func SceneLoaderDidComplete(notification: Notification) {
        
        // Unpack the notification
        guard let sceneLoader: SceneLoader = notification.userInfo?["sceneLoader"] as? SceneLoader else {
            return
        }
        
        Task {
             
            // Check the scene loader notification to whats cached
            guard let requestedScene: SceneLoader = self.sceneLoader(forSceneIdentifier: requestedScene), requestedScene === sceneLoader else {
                return
            }
            
            // Cache scene loader
            self.presentSceneLoader = sceneLoader
        }
    }
    
    /// Progress scene has finished loading animation
    @objc func progressSceneAnimationComplete() {
        
        guard let loader = self.presentSceneLoader, loader.stateMachine.currentState is SLResourcesReadyState else {
            fatalError("Received complete notification, but the stateMachine's current state is not ready.")
        }

        presentScene(loader: loader)
    }
}

extension SceneManager {
    
    
    // Returns the scene loader associated with the scene identifier.
    func sceneLoader(forSceneIdentifier sceneIdentifier: SceneIdentifier) -> SceneLoader? {
        
        let sceneLoader: SceneLoader?
        
        switch sceneIdentifier {
        case .intro:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == IntroScene.self})
        case .mainMenu:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == MainMenuScene.self})
        case .options:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == OptionScene.self})
        case .loadGame:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == LoadGameScene.self})
        case .progress:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == ProgressScene.self})
        case .gameLevel(_):
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == LevelScene.self})
        case .gameMenu:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == GameMenuScene.self})
        case .credits:
            sceneLoader = sceneLoaders.first(where: {$0.sceneMetadata.sceneType == CreditsScene.self})
        }
        
        return sceneLoader
    }
}

extension SceneManager: SceneDelegate {
    
    func transitionToScene(scene: SceneIdentifier, secondsDelay: Double) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsDelay, execute: {
            self.transitionToScene(identifier: scene)
        })
    }
}

extension SceneManager {
    
    
    // -----------------------------------------------------------------
    // MARK: - Development tool access
    // -----------------------------------------------------------------
    
    static public func executeDebugRequests(type: GameplayConfiguration.Debug.Setting, task: () -> Void) {
        
        // Execute development code only if build is in debug
        switch SceneManager.gameBuild {
        case .development where GameplayConfiguration.Debug.settingEnabled(type: type):
            task()
        case .production:
            return
        default:
            return
        }
    }
    
    static public func executeDebugRequests(task: () -> Void) {
        
        // Execute development code only if build is in debug
        switch SceneManager.gameBuild {
        case .development:
            task()
        case .production:
            return
        }
    }
}
