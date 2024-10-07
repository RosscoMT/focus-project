//
//  SceneManager+Extension.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 22/03/2023.
//

import Foundation

extension SceneManager {
    
    
    // -----------------------------------------------------------------
    // MARK: - SceneLoader Notifications
    // -----------------------------------------------------------------
    
    func setupNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SceneLoaderDidComplete(notification:)),
                                               name: .sceneLoaderDidComplete,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(progressSceneAnimationComplete),
                                               name: .progressAnimationsCompleted,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(requiredSceneLoaderDidComplete),
                                               name: .requiredSceneLoaderDidComplete,
                                               object: nil)
    }
}
