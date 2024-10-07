//
//  CharacterBot+Resources.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 11/06/2023.
//

import SpriteKit
import Engine

extension CharacterBot: ResourceLoadableType {
    
    
    // -----------------------------------------------------------------
    // MARK: - ResourceLoadableType
    // -----------------------------------------------------------------
    
    static var resourcesNeedLoading: Bool {
        return CharacterBot.animations.isEmpty
    }
    
    static func loadResources() async {
        
        typealias AnimationIdentifiers = GameplayConfiguration.PlayerBot.AnimationIdentifer
        
        // Atlases refer to the folders within the image assets file by their name i.e CharacterIdle
        let customerAtlases: [EnityAtlas.Player] = [.playerBotIdle, .playerBotWalk]
        
        // Preload all of the texture atlases for Customer. This improves the overall loading speed of the animation cycles for this character.
        do {
            let characterAtlases: [SKTextureAtlas] = try await SKTextureAtlas.preloadTextureAtlasesNamed(customerAtlases)
            
            // Clear any cached animation sprites
            CharacterBot.animations.removeAll()
            
            // Load in the animations by cayegory - The atlases and states much match up or textures will fail to be loaded
            CharacterBot.animations[.idle] = AnimationComponent.animationsFromAtlas(atlas: characterAtlases[0],
                                                                                    withImageIdentifier: AnimationIdentifiers.idle,
                                                                                    forAnimationState: AnimationState.idle)
            
            CharacterBot.animations[.walkBackward] = AnimationComponent.animationsFromAtlas(atlas: characterAtlases[1],
                                                                                            withImageIdentifier: AnimationIdentifiers.walking,
                                                                                            forAnimationState: .walkBackward,
                                                                                            playBackwards: true)
            
            CharacterBot.animations[.walkForward] = AnimationComponent.animationsFromAtlas(atlas: characterAtlases[1],
                                                                                           withImageIdentifier: AnimationIdentifiers.walking,
                                                                                           forAnimationState: .walkForward)
            
        } catch {
            fatalError("One or more texture atlases could not be found: \(error)")
        }
    }
    
    static func purgeResources() {
        animations.removeAll()
    }
}
