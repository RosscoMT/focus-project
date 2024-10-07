//
//  LoadResources.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 22/11/2022.
//

import Foundation

/// Load resources
class LoadResources: NSObject {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // A class that conforms to the `ResourceLoadableType` protocol.
    let loadableType: ResourceLoadableType.Type
   
    
    // ------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    init(loadableType: ResourceLoadableType.Type) {
        self.loadableType = loadableType
        super.init()
    }
    
    func start() async {
   
        // Avoid reloading the resources if they are already available.
        guard loadableType.resourcesNeedLoading else {
            return
        }

        await loadableType.loadResources()
    }
}
