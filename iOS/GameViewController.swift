//
//  GameViewController.swift
//  Coffee House
//
//  Created by Ross Viviani on 24/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import UIKit
import SpriteKit
import Controls

class GameViewController: UIViewController, SceneManagerDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // A placeholder logo view that is displayed before the home scene is loaded.
    @IBOutlet weak var logoView: UIImageView!
    
    // A manager for coordinating scene resources and presentation.
    var sceneManager: SceneManager!
    
    
    // -----------------------------------------------------------------
    // MARK: - View Life Cycle
    // -----------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the `touchControlInputNode` to cover the entire view, and size the controls to a reasonable value.
        let controlLength: CGFloat = min(GameplayConfiguration.TouchControl.minimumControlSize, view.bounds.size.width * GameplayConfiguration.TouchControl.idealRelativeControlSize)
        
        let touchControlInputNode: TouchControlInputSource = TouchControlInputSource(frame: view.bounds,
                                                                                 configuration: .init(CGSize(width: controlLength, height: controlLength), 0))
        let gameInput: GameInput = GameInput(nativeControlInputSource: touchControlInputNode)
        
        do {
            guard let skView: SKView = view as? SKView else {
                fatalError("Unable to initialise SKView")
            }
            
            #if DEBUG
            skView.showsPhysics = true
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsDrawCount = true
            #endif
            
            skView.ignoresSiblingOrder = true
            
            sceneManager = try SceneManager(presentingView: skView, gameInput: gameInput)
            sceneManager.delegate = self
        } catch {
            fatalError()
        }
    }
    
    // Hide status bar during game play.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - SceneManagerDelegate
    // -----------------------------------------------------------------
    
    func sceneManager(_ sceneManager: SceneManager, didTransitionTo scene: SKScene) {
//        // Fade out the app's initial loading `logoView` if it is visible.
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
//            self.logoView.alpha = 0.0
//        }, completion: { _ in
//            self.logoView.isHidden = true
//        })
    }
}

