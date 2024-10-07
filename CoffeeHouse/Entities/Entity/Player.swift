//
//  Player.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 17/05/2022.
//

import GameplayKit
import Engine

class Player: GKEntity, EntityAttributes {
    
    var shadowOffset: CGPoint = CGPoint(x: 0.0, y: -40.0)
    
    var animations: [AnimationState: [CompassDirection: Animation]]?
    
    var textureSize: CGSize = CGSize(width: 120.0, height: 120.0)
    
    var shadowSize: CGSize = CGSize(width: 90.0, height: 40.0)
    
    var appearTextures: [CompassDirection: SKTexture]?
    
    let agent: GKAgent2D = GKAgent2D()
    
    override init() {
        
        super.init()
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let animationComponent = AnimationComponent(textureSize: self.textureSize, animations: self.animations!)
        addComponent(animationComponent)
        
        renderComponent.node.addChild(animationComponent.node)
        animationComponent.shadowNode = shadowComponent.node
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var resourcesNeedLoading: Bool {
        return appearTextures == nil || animations == nil
    }
    
 
    func loadResources(withCompletionHandler completionHandler: @escaping () -> ()) {
   
        let playerBotAtlasNames = [
            "PlayerBotIdle",
            "PlayerBotWalk",
            "PlayerBotInactive",
            "PlayerBotHit"
        ]
        
        /*
         Preload all of the texture atlases for `PlayerBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(playerBotAtlasNames) { error, playerBotAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `PlayerBot` animations
             after the `PlayerBot` texture atlases have finished preloading.
             
             Store the first texture from each direction of the `PlayerBot`'s idle animation,
             for use in the `PlayerBot`'s "appear"  state.
             */
            self.appearTextures = [:]
            for orientation in CompassDirection.allDirections {
                self.appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(compassDirection: orientation, inAtlas: playerBotAtlases[0], withImageIdentifier: "PlayerBotIdle")
            }
            
            // Set up all of the `PlayerBot`s animations.
            self.animations = [:]
            self.animations![.idle] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[0], withImageIdentifier: "PlayerBotIdle", forAnimationState: .idle)
            self.animations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[1], withImageIdentifier: "PlayerBotWalk", forAnimationState: .walkForward)
            self.animations![.walkBackward] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[1], withImageIdentifier: "PlayerBotWalk", forAnimationState: .walkBackward, playBackwards: true)
            self.animations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[2], withImageIdentifier: "PlayerBotInactive", forAnimationState: .inactive)
            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
    }
}
