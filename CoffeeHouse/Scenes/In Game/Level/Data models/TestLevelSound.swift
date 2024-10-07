//
//  LevelSound.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 20/06/2023.
//

import SpriteKit
import Engine

class TestLevelSound: ResourceLoadableType {
    
    
    // -----------------------------------------------------------------
    // MARK: - Sound assets
    // -----------------------------------------------------------------
    
    static var backgroundAudio: SKAudioNode?
    
    
    // -----------------------------------------------------------------
    // MARK: - Resource Management Methods
    // -----------------------------------------------------------------
    
    static var resourcesNeedLoading: Bool = {
        return TestLevelSound.backgroundAudio == nil
    }()
    
    static func loadResources() async {
        
        do {
            TestLevelSound.backgroundAudio = try SoundToolKit.loadMusicFile(resourceURL: Resources.levelBackgroundMusic.resourcesURL())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func purgeResources() {
        TestLevelSound.backgroundAudio = nil
    }
}

