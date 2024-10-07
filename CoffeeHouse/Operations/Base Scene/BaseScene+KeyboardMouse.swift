//
//  BaseScene+KeyboardMouse.swift
//
//
//  Created by Ross Viviani on 05/12/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import Engine

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/* BaseScene+KeyboardMouse scene extension is setup to handle both keyboard and mouse inputs across supported platforms.
 
 As SKScene is typically (Not if the scene uses MTKView ie Metal View) first place that receives gameplay input. The baseScene extension is used to capture the input and send it elsewhere to be processed.
 */
extension BaseScene {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
  
    var keyboardControlInputSource: KeyboardControlInputSource {
        return sceneManager.gameInput.nativeControlInputSource as! KeyboardControlInputSource
    }
    
    #if os(macOS)
    
    // -----------------------------------------------------------------
    // MARK: - MacOS Mouse Input
    // -----------------------------------------------------------------
    
    override func mouseDown(with event: NSEvent) {
        keyboardControlInputSource.handleMouseDownEvent(.init(event))
        
        // Create an initial time interval
        longPressCounter = .zero
        
        // Capture the mouse down for long press
        mouseDownTimeStamp = Date()
        
        // Append a new date
        doubleTapCount.appendNewDate()
        
        // Setup a timer to track how long the user has kept
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            
            self?.longPressCounter += timer.timeInterval
            
            if let counter = self?.longPressCounter, counter >= configuration.longPressDuration {
                self?.resetLongPressTimer()
                self?.keyboardControlInputSource.handleLongMouseDownEvent(.init(event), input: .down)
            }
        }
        
        longPressTimer?.fire()
    }
    
    override func mouseUp(with event: NSEvent) {
        keyboardControlInputSource.handleMouseUpEvent(.init(event))

        // Process double tap counter if value equals or exceeds 2
        if doubleTapCount.count >= 2 {
  
            // Check the difference in seconds between the two dates
            if doubleTapCount.first!.secondDifference() <= configuration.longPressDuration {
                keyboardControlInputSource.handleMouseDoubleTapEvent(.init(event))
            }
            
            doubleTapCount.removeAll()
        }
        
        // Reset any running timers
        if mouseDownTimeStamp!.secondDifference() >= configuration.longPressDuration {
            keyboardControlInputSource.handleLongMouseDownEvent(.init(event), input: .up)
        }
        
        resetLongPressTimer()
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        // Reset the double tap counter if it contains any values
        if doubleTapCount.isEmpty == false {
            doubleTapCount.removeAll()
        }
        
        keyboardControlInputSource.handleMouseDragEvent(.init(event))
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Gesture Recogniser
    // -----------------------------------------------------------------
    
    @objc func pinchGesture(_ gesture: NSMagnificationGestureRecognizer) {
        keyboardControlInputSource.handleMousePinchGesture(gesture)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - MacOS Keyboard Input
    // -----------------------------------------------------------------
    
    override func keyDown(with event: NSEvent) {
        keyDown(characters: event.charactersIgnoringModifiers ?? "")
    }
    
    override func keyUp(with event: NSEvent) {
        keyUp(characters: event.charactersIgnoringModifiers ?? "")
    }
    
    #elseif os(iOS)
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        // The game currently only supports iPad keyboard
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        
        keyDown(characters: presses.map({$0.key?.charactersIgnoringModifiers ?? ""}).reduce("", +))
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        // The game currently only supports iPad keyboard
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        
        keyUp(characters: presses.map({$0.key?.charactersIgnoringModifiers ?? ""}).reduce("", +))
    }
  
    #endif
    
    
    // -----------------------------------------------------------------
    // MARK: - Keyboard Handling
    // -----------------------------------------------------------------
    
    
    func keyDown(characters: String) {
        characters.forEach({keyboardControlInputSource.handleKeyDown(forCharacter: $0)})
    }
    
    func keyUp(characters: String) {
        characters.forEach({keyboardControlInputSource.handleKeyUp(forCharacter: $0)})
    }
 
    // Reset the timer
    func resetLongPressTimer() {
        longPressCounter = .zero
        longPressTimer?.invalidate()
    }
}
