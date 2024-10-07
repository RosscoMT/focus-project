//
//  ProgressScene.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import Engine

/// A scene used to indicate the progress of loading additional content between scenes.
class ProgressScene: BaseScene, RendererSpriteKitScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    override var backgroundNode: SKSpriteNode? {
        return childNode(name: GameNodes.backgroundNode) as? SKSpriteNode
    }
     
    private var labelNode: SKLabelNode? {
        return backgroundNode!.childNode(name: GameNodes.progressLabel) as? SKLabelNode
    }
    
    private var progressBarBackgroundNode: SKSpriteNode? {
        return backgroundNode!.childNode(name: GameNodes.progressBarBackground) as? SKSpriteNode
    }
    
    private var progressBarNode: SKSpriteNode? {
        return backgroundNode!.childNode(name: GameNodes.progressBar) as? SKSpriteNode
    }
    
    typealias ScenesConfig = GameplayConfiguration.ProgressScene
    
    
    // Store progress bars width
    private var progressBarInitialWidth: CGFloat = 0
    
    // Track progress as the resources are loaded
    private var progressTotal: Int = 0
    private var progressCounter: Int = 0
    
    
    // -----------------------------------------------------------------
    // MARK: - Setup
    // -----------------------------------------------------------------
    
    func setupSKScene(with manager: SceneManager) {
        
        self.sceneManager = manager
        
        super.setupSKScene()
        
        guard let position: CGPoint = backgroundNode?.position as? CGPoint else {
            return
        }
        
        centerCameraOnPoint(point: position)
        
        let progressBarBackgroundNodeWidth = progressBarBackgroundNode?.frame.width ?? 0
        
        // Remember the progress bar's initial width. It will change to indicate progress.
        progressBarInitialWidth = ((progressBarBackgroundNodeWidth) / CGFloat(progressTotal))
        
        // Setup the render
//        skRenderer = SKRenderer(device: Renderer.device)
//        skRenderer?.scene = self
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    func update(progressTotal: Int) {
        
        // Cache total tasks
        self.progressTotal = progressTotal
    
        self.createCamera()

        // Register for notifications posted when the progress updates or scene downloader fails.
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(notification:)),
                                               name: .sceneLoaderUpdate,
                                               object: nil)
    }
    
    // -----------------------------------------------------------------
    // MARK: - Notification handling
    // -----------------------------------------------------------------
    
    @objc func updateProgress(notification: Notification) {
 
        // Store counter for the next call
        self.progressCounter += 1
        
        // Run the progress bar animation using the original width and progress bar counter
        self.progressBarNode?.run(SKAction.resize(toWidth: (self.progressBarInitialWidth) * CGFloat(self.progressCounter),
                                                  duration: ScenesConfig.progressBarAnimationDuration), completion: {
            self.progressTotal -= 1
            
            if self.progressTotal == 0 {
                self.completedAllAnimations()
            }
        })
    }
    
    // -----------------------------------------------------------------
    // MARK: - Animation Methods
    // -----------------------------------------------------------------
    
    @MainActor
    func completedAllAnimations() {
        NotificationCenter.default.post(name: .progressAnimationsCompleted, object: nil)
    }
    
    func showError(_ error: GameErrors) {
        
        // Check if the error was due to the user cancelling the operation.
        switch error {
        case .downloadFailed(let value) where (value.contains(NSCocoaErrorDomain) && value.contains(NSCocoaErrorDomain)):
            labelNode?.text = NSLocalizedString("Cancelled", comment: "Displayed when the user cancels loading.")
        case .sceneLoader(let value) where (value.contains(NSCocoaErrorDomain) && value.contains(NSCocoaErrorDomain)):
            labelNode?.text = NSLocalizedString("Cancelled", comment: "Displayed when the user cancels loading.")
        default:
            showAlert(for: error)
        }
    }
    
    // -----------------------------------------------------------------
    // MARK: - Alert Handling
    // -----------------------------------------------------------------
    
    func showAlert(for error: Error) {
        self.labelNode?.text = NSLocalizedString("Failed", comment: "Displayed when the scene loader fails to load a scene.")
        
        // Display the error description in a native alert.
        #if os(OSX)
            guard let window: NSWindow = view?.window else {
                fatalError("Attempting to present an error when the scene is not in a window.")
            }
             
            let alert: NSAlert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: nil)
        #else
        
            guard let rootViewController: UIViewController = view?.window?.rootViewController else {
                fatalError("Attempting to present an error when the scene is not in a view controller.")
            }
            
            let alert: UIAlertController = UIAlertController(title: error.localizedDescription,
                                                             message: error.localizedDescription,
                                                             preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            rootViewController.present(alert, animated: true, completion: nil)
        #endif
    }
}
