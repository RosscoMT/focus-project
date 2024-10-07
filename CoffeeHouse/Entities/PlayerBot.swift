//
//  PlayerBot.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import GameplayKit
import Engine

/// A GKEntity subclass that represents the player-controlled character. This subclass allows for convenient construction of a new entity with appropriate GKComponent instances.
class PlayerBot: GKEntity, ResourceLoadableType {
    
    typealias Config = GameplayConfiguration.PlayerBot
    
    // -----------------------------------------------------------------
    // MARK: - Static Properties
    // -----------------------------------------------------------------
    
    // The unique attributes of this entity
    static var attribute: EntityAttributes = {
        return .init(textureSize: CGSize(width: 120.0, height: 120.0))
    }()
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------

    static var animations: [AnimationState: [CompassDirection: Animation<AnimationState>]]?
 
    var renderComponent: RenderComponent {
        
        guard let renderComponent: RenderComponent = component(ofType: RenderComponent.self) else {
            fatalError("A PlayerBot must have an RenderComponent.")
        }
        
        return renderComponent
    }

    var inputComponent: InputComponent {
        
        guard let inputComponent: InputComponent = component(ofType: InputComponent.self) else {
            fatalError("A PlayerBot must have an RenderComponent.")
        }
        
        return inputComponent
    }
    
    let agent: GKAgent2D

    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------

    override init() {
        agent = GKAgent2D()
        agent.radius = Config.agentRadius
        
        super.init()
        
        // Add the `RenderComponent` before creating the `IntelligenceComponent` states, so that they have the render node available to them when first entered (e.g. so that `PlayerBotAppearState` can add a shader to the render node).
        let renderComponent: RenderComponent = RenderComponent()
        renderComponent.spriteNode?.zPosition = WorldLayerPositioning.characters.rawValue
        
        let orientationComponent: OrientationComponent = OrientationComponent()
        let inputComponent: InputComponent = InputComponent()
        
        // Add the movement and charge components
        let movementComponent: MovementComponent = MovementComponent()

        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animations: [AnimationState: [CompassDirection: Animation<AnimationState>]] = PlayerBot.animations else {
            fatalError("Attempt to access PlayerBot.animations before they have been loaded.")
        }
        
        // Add animation components
        let animationComponent: AnimationComponent = AnimationComponent<AnimationState>(textureSize: PlayerBot.attribute.textureSize,
                                                                        animations: animations)
        animationComponent.node.zPosition = WorldLayerPositioning.characters.rawValue
 
        // Connect the `RenderComponent` to the `AnimationComponent`.
        renderComponent.spriteNode = animationComponent.node
        
        let physicsComponent: PhysicsComponent = PhysicsComponent()
        physicsComponent.category = PhysicsCategory.player.rawValue
        physicsComponent.shape = PhysicsShape.rect.rawValue

        let intelligenceComponent: IntelligenceComponent = IntelligenceComponent(states: [
            PlayerBotAppearState(entity: self),
            PlayerBotPlayerControlledState(entity: self),
        ])
     
        // Add the components the the entity
        addComponents([renderComponent, orientationComponent, inputComponent, physicsComponent, movementComponent, animationComponent, intelligenceComponent])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Turn players physics static and cancel input when in the LevelSceneEditorState
    func updateMachineState(_ currentState: GKState?) {
        //renderComponent.spriteNode?.physicsBody?.isDynamic = currentState is LevelSceneEditorState ? false : true
        inputComponent.isEnabled = currentState is LevelSceneEditorState ? false : true
    }
    
    func setLighting(type: LightingType) {
        renderComponent.spriteNode?.lightingBitMask = type.categoryMask
        renderComponent.spriteNode?.shadowedBitMask = type.shadowedBitMask
        renderComponent.spriteNode?.shadowCastBitMask = type.shadowCastBitMask
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Resource Management Methods
    // -----------------------------------------------------------------

    static var resourcesNeedLoading: Bool {
        return PlayerBot.attribute.appearTextures == nil || PlayerBot.animations == nil
    }
    
    static func loadResources() async {
        
        typealias AnimationIdentifiers = GameplayConfiguration.PlayerBot.AnimationIdentifer
        
        let playerAtlas: [EnityAtlas.Player] = [.playerBotIdle, .playerBotWalk]
        
        // Preload all of the texture atlases for `PlayerBot`. This improves the overall loading speed of the animation cycles for this character.
        do {
            let playerBotAtlases: [SKTextureAtlas] = try await SKTextureAtlas.preloadTextureAtlasesNamed(playerAtlas)
            
            // This closure sets up all of the `PlayerBot` animations after the `PlayerBot` texture atlases have finished preloading. Store the first texture from each direction of the `PlayerBot`'s idle animation, for use in the `PlayerBot`'s "appear"  state.
            PlayerBot.attribute.appearTextures = [:]
            
            for orientation in CompassDirection.allCases {
                PlayerBot.attribute.appearTextures![orientation] = AnimationComponent<AnimationState>.firstTextureForOrientation(compassDirection: orientation,
                                                                                                                 inAtlas: playerBotAtlases[0],
                                                                                                                 withImageIdentifier: AnimationIdentifiers.idle)
            }
            
            // Set up all of the `PlayerBot`s animations.
            PlayerBot.animations = [:]
            
            PlayerBot.animations![.idle] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[0],
                                                                                  withImageIdentifier: AnimationIdentifiers.idle,
                                                                                            forAnimationState: .idle)
            
            PlayerBot.animations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[1],
                                                                                         withImageIdentifier: AnimationIdentifiers.walking,
                                                                                                   forAnimationState: .walkForward)
            
            PlayerBot.animations![.walkBackward] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[1],
                                                                                          withImageIdentifier: AnimationIdentifiers.walking,
                                                                                          forAnimationState: .walkBackward,
                                                                                          playBackwards: true)
            
        } catch {
            fatalError("One or more texture atlases could not be found: \(error)")
        }
    }
    
    static func purgeResources() {
        PlayerBot.animations = nil
    }

    
    // -----------------------------------------------------------------
    // MARK: - Convenience
    // -----------------------------------------------------------------

    // Sets the `PlayerBot` `GKAgent` position to match the node position (plus an offset).
    func updateAgentPositionToMatchNodePosition() {
        
        // `renderComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let renderComponent: RenderComponent = self.renderComponent
        
        let agentOffset: CGPoint = GameplayConfiguration.PlayerBot.agentOffset
        
        // Update the entities positioning
        agent.updatePositioning(xAxis: Float(renderComponent.spriteNode?.position.x ?? .zero + agentOffset.x),
                                yAxis: Float(renderComponent.spriteNode?.position.y ?? .zero + agentOffset.y))
    }
}
