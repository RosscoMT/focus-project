//
//  SKTextureAtlas+Extension.swift
//  
//
//  Created by Ross Viviani on 31/12/2022.
//

import GameplayKit

/// These are useful extensions for the texture atlas
public extension SKTextureAtlas {
    
    // -----------------------------------------------------------------
    // MARK: - Private methods
    // -----------------------------------------------------------------
    
    /// Local method for both adding returning the enums raw string values and a captialising letter the initial character
    private static func names<T: RawRepresentable<String>>(_ value: [T]) -> [String] {
        
        // Using the standard methods for capalising or uppercasing will wipe out the other casing
        return value.map({ item in
            return item.rawValue.captializeString()
        })
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Public methods
    // -----------------------------------------------------------------
    
    /// Allows for handling enum based texture alases names
    static func preloadTextureAtlasesNamed<T: RawRepresentable<String>>(_ value: [T]) async throws -> [SKTextureAtlas] {
        try await SKTextureAtlas.preloadTextureAtlasesNamed(SKTextureAtlas.names(value))
    }
}
