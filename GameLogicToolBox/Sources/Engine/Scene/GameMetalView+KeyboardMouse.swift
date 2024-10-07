//
//  GameMetalView+KeyboardMouse.swift
//
//
//  Created by Ross Viviani on 01/09/2024.
//

import SpriteKit

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

extension GameMetalView {
    
    var scene: SKScene {
        guard let scene = Renderer.scene else {
            fatalError("No scene has been assigned to this render")
        }
        
        return scene
    }
    
    #if os(macOS)
    
    public override func mouseDown(with event: NSEvent) {
        scene.mouseDown(with: event)
    }
    
    public override func mouseUp(with event: NSEvent) {
        scene.mouseUp(with: event)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        scene.mouseDragged(with: event)
    }
    
    public override func keyDown(with event: NSEvent) {
        scene.keyDown(with: event)
    }
    
    public override func keyUp(with event: NSEvent) {
        scene.keyUp(with: event)
    }
    
    #elseif os(iOS)
    
    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        scene.pressesBegan(presses, with: event)
    }
    
    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        scene.pressesEnded(presses, with: event)
    }
    
    #endif
    
}
