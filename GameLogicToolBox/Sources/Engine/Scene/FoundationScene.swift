//
//  FoundationScene.swift
//  
//
//  Created by Ross Viviani on 19/11/2022.
//

import SpriteKit

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

/// A base layer which holds the most commonly needed methods and functions
open class FoundationScene: SKScene {
    
    // The native size for this scene. This is the height at which the scene would be rendered if it did not need to be scaled to fit a window or device. Defaults to `zeroSize`; the actual value to use is set in `createCamera()`.
    open var nativeSize: CGSize = .zero
    
    // The background node for this `BaseScene` if needed. Provided by those subclasses that use a background scene in their SKS file to center the scene on screen.
    open var backgroundNode: SKSpriteNode? {
        return nil
    }
    
    // A flag to indicate if focus based navigation is currently enabled. Also used to ensure buttons are navigated at a reasonable rate by toggling this flag after a short delay in `controlInputSource(_: didSpecifyDirection:)`.
    open var focusChangesEnabled: Bool = false
    
    
    // -----------------------------------------------------------------
    // MARK: - Life cycle
    // -----------------------------------------------------------------
    
    public override init() {
        super.init()
        
        #if os(macOS)
        
        // Add observer for macOS resigned notification
        NotificationCenter.default.addObserver(self, selector: #selector(pauseScene), name: NSApplication.willResignActiveNotification, object: nil)
        
        #endif
        
        #if os(iOS)
        
        // Add observer for iOS resigned notification
        NotificationCenter.default.addObserver(self, selector: #selector(pauseScene), name: UIApplication.willResignActiveNotification, object: nil)
        
        #endif
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    @objc open func pauseScene() {
       // Action for pausing of game
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Camera Actions
    // -----------------------------------------------------------------
    
    // Creates a camera for the scene, and updates its scale. This method should be called when initializing an instance of a `BaseScene` subclass.
    open func createCamera() {
        
        // If the scene has a background node, use its size as the native size of the scene. // Otherwise, use the scene's own size as the native size of the scene.
        if let backgroundNode: SKSpriteNode = backgroundNode {
            nativeSize = backgroundNode.size
        } else {
            nativeSize = size
        }
        
        let camera: SKCameraNode = SKCameraNode()
        self.camera = camera
        addChild(camera)
        
        updateCameraScale()
    }
    
    // Centers the scene's camera on a given point.
    open func centerCameraOnPoint(point: CGPoint) {
        if let camera: SKCameraNode = camera {
            camera.position = point
        }
    }
    
    // Scales the scene's camera.
    open func updateCameraScale() {
        
        // Because the game is normally playing in landscape, use the scene's current and original heights to calculate the camera scale.
        if let camera: SKCameraNode = camera {
            camera.setScale(nativeSize.height / size.height)
        }
    }
    
    
    /// Use for detecting gameplay area from the camera node
    /// - Parameters:
    ///   - location: The point where the camera node should check from
    ///   - avoid: Requested nodes to avoid by name
    /// - Returns: Boolean value equals if the location contains the to avoid node
    open func gameplayArea(location: CGPoint, avoid: [String]) -> Bool {
        
        guard let camera = self.camera else {
            return false
        }
        
        let nodes: [SKNode] = camera.nodes(at: self.convert(location, to: camera))
        
        let nodeNames: [String] = nodes.compactMap({$0.name})
        var result: Bool = true
        
        if nodeNames.isEmpty {
            return true
        } else {
            
            // Cycle through detected nodes
            for node in nodeNames {
                
                // Cycle through nodes to avoid
                for advoidNode in avoid {
                    
                    // If the nodes match break and return false
                    if advoidNode == node {
                        result = false
                        break
                    }
                }
            }
            
            return result
        }
    }
    
}
