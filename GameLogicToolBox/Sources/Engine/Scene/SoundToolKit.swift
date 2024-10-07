//
//  SoundToolKit.swift
//  
//
//  Created by Ross Viviani on 04/05/2023.
//

import Foundation
import SpriteKit
import AVFoundation

public struct SoundToolKit {
    
    // Data model for storing audio settings
    public struct SoundModel {
        let delay: Double
        let volume: Float
        let volumeChangeDuration: Double
        
        public init(delay: Double, volume: Float, volumeChangeDuration: Double) {
            self.delay = delay
            self.volume = volume
            self.volumeChangeDuration = volumeChangeDuration
        }
    }
    
    static public func playSound(node: SKNode, audioNode: SKAudioNode,
                          autoplayLooped: Bool = false,
                          isPositional: Bool = true) {
        
        audioNode.autoplayLooped = autoplayLooped
        audioNode.isPositional = isPositional
        
        node.addChild(audioNode)
        audioNode.run(SKAction.play())
    }
    
    // Add the game music to the game
    static public func playMusic<T: SKScene>(scene: T, audioNode: SKAudioNode, config: SoundModel) {
        
        // Mute audio initially
        scene.audioEngine.mainMixerNode.outputVolume = 0.0
        
        // Setup looping and positional information
        audioNode.autoplayLooped = true
        audioNode.isPositional = false
        
        scene.addChild(audioNode)
        
        // Mute the audio node
        audioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        
        // Run the process of increasing the main audio and audio node
        scene.run(SKAction.wait(forDuration: config.delay), completion: { [unowned scene] in
            scene.audioEngine.mainMixerNode.outputVolume = 1.0
            audioNode.run(SKAction.changeVolume(to: config.volume, duration: config.volumeChangeDuration))
        })
    }
    
    // Add the game music to the game
    static public func adjustAudio(audioNode: SKAudioNode, changeVolumeTo: Float) {
        audioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Resource Management Methods
    // -----------------------------------------------------------------
    
    /// Loads a short sound file to memory before usage
    static public func loadAudioFile(resource: String) -> SKAction {
        return SKAction.playSoundFileNamed(resource, waitForCompletion: true)
    }
    
    /// Loads music file to memory before usage
    static public func loadMusicFile(resourceURL: URL?) throws -> SKAudioNode {
        
        guard let url = resourceURL else {
            throw GameErrors.missingResource
        }
        
        return SKAudioNode(url: url)
    }
}
