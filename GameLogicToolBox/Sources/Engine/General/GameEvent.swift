//
//  GameEvent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 21/11/2023.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct GameEvent {
    #if os(macOS)
    public let data: NSEvent
    
    public init(_ data: NSEvent) {
        self.data = data
    }
    #else
    let data: UITouch
    
    public init(_ data: UITouch) {
        self.data = data
    }
    #endif
}
