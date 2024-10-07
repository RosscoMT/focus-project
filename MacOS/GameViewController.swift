//
//  GameViewController.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 24/08/2024.
//

import AppKit
import Engine
import MetalKit

class GameViewController: NSViewController {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // A manager for coordinating scene resources and presentation.
    var sceneManager: SceneManager!
    var renderer: Renderer?
    
    // -----------------------------------------------------------------
    // MARK: - View Life Cycle
    // -----------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Control input by platform
        let keyboardControlInputSource = KeyboardControlInputSource()
        let gameInput = GameInput(nativeControlInputSource: keyboardControlInputSource)
        
        do {
            
            // Load the initial home scene.
            guard let metalView = view as? GameMetalView else {
                fatalError("Unable to initialise MTKView")
            }
            
            renderer = Renderer(metalView: metalView)
            sceneManager = try SceneManager(gameInput: gameInput)
        } catch {
            fatalError()
        }
    }
}
