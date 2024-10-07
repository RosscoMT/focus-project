//
//  File.swift
//  
//
//  Created by Ross Viviani on 09/09/2024.
//

import Foundation
import SpriteKit

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public extension NSEvent {
    
    func location(scene: SKScene) -> NSPoint? {
        
        guard let hitPoint = Renderer.metalView?.convert(self.locationInWindow, from: nil), let scaleWidth = Renderer.metalView?.bounds.width else {
            return nil
        }
       
        return NSPoint(x: hitPoint.x, y: hitPoint.y)
    }
}
