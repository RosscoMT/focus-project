//
//  GameDelegates.swift
//  
//
//  Created by Ross Viviani on 22/07/2023.
//

import Foundation

/// Enum protocol for using the handle func
public protocol Handle {
    func handle() -> String
}

/// Convenience methods for Handle protocol
public extension Collection where Element: Handle {
    
    /// Quickly return the arrays handle values
    /// - Returns: A non-nil array of string values
    func handleRawValues() -> [String] {
        return self.compactMap({$0.handle()})
    }
}

/// Delegate for holding configuration special methods
public protocol GameConfigDelegate  {
    static func settingModel() -> Factory.FactoryAgent
}
