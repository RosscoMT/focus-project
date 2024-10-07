//
//  CharacterBot.swift
//  Coffee House
//
//  Created by Ross Viviani on 12/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import SpriteKit
import GameplayKit
import Engine

class CharacterBot: FoundationEntity {
    
    enum MachineStates {
        case walkState
        case idleState
        case servedState
        case sitState
        case sitDownState
    }
    
    typealias Config = GameplayConfiguration.PlayerBot
    typealias ConfigScene = GameplayConfiguration.Level
    
    
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
    
    var type: CharacterType?
    
    // The animations to use for a entities
    static var animations: [AnimationState: [CompassDirection: Animation<AnimationState>]] = [:]
    
    var agentComponent: AgentComponent {
        
        guard let agentComponent: AgentComponent = component(ofType: AgentComponent.self) else {
            fatalError("A CharacterBot missing agent component.")
        }
        
        return agentComponent
    }
    
    var rulesComponent: RulesComponent {
        
        guard let rulesComponent: RulesComponent = component(ofType: RulesComponent.self) else {
            fatalError("A CharacterBot missing rules component.")
        }
        
        return rulesComponent
    }
    
    var intelligenceComponent: IntelligenceComponent {
        
        guard let intelligenceComponent: IntelligenceComponent = component(ofType: IntelligenceComponent.self) else {
            fatalError("A CharacterBot missing intelligence component.")
        }
        
        return intelligenceComponent
    }
    
    var physicsComponent: PhysicsComponent {
        
        guard let physicsComponent: PhysicsComponent = component(ofType: PhysicsComponent.self) else {
            fatalError("A CharacterBot missing intelligence component.")
        }
        
        return physicsComponent
    }
    
    var orientationComponent: OrientationComponent {
        
        guard let orientationComponent: OrientationComponent = component(ofType: OrientationComponent.self) else {
            fatalError("A CharacterBot missing intelligence component.")
        }
        
        return orientationComponent
    }
    
    var animationComponent: AnimationComponent<AnimationState> {
        
        guard let animationComponent: AnimationComponent = component(ofType: AnimationComponent<AnimationState>.self) else {
            fatalError("A CharacterBot missing intelligence component.")
        }
        
        return animationComponent
    }
    
    // The current aim of the CharacterBot
    var currentMandate: CustomerMandate? {
        didSet {
            
            // Remove any previously used pad
            clearPad()
        }
    }
    
    lazy var level: LevelScene = {
        
        if let level = componentNode.parent?.scene as? LevelScene {
            return level
        } else {
            fatalError("This bot requires level scene as its parent")
        }
    }()
  
    var interactingWithPad: SKNode?
    
    
    // -----------------------------------------------------------------
    // MARK: - Life cycle
    // -----------------------------------------------------------------
    
    init(_ value: CharacterType? = nil) {
        super.init()
        self.type = value ?? CharacterType.random()
        self.currentMandate = .enterScene
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Setup
    // -----------------------------------------------------------------
    
    func setupComponents(scene: LevelScene) {
        
        let renderComponent: RenderComponent = RenderComponent()
    
        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animations: [AnimationState: [CompassDirection: Animation<AnimationState>]] = PlayerBot.animations else {
            fatalError("Attempt to access PlayerBot.animations before they have been loaded.")
        }
        
        // Add animation components
        let animationComponent: AnimationComponent<AnimationState> = AnimationComponent(textureSize: PlayerBot.attribute.textureSize,
                                                                                        animations: animations)
        
        renderComponent.spriteNode = animationComponent.node
        renderComponent.spriteNode?.name = "Character"
        renderComponent.spriteNode?.zPosition = WorldLayerPositioning.characters.rawValue
        
        let orientationComponent: OrientationComponent = OrientationComponent()
   
        // Add the animation states for the customer
        let intelligenceComponent: IntelligenceComponent = IntelligenceComponent(states: [
            CustomerWalkState(entity: self),
            CustomerIdleState(entity: self),
            CustomerServedState(entity: self),
            CustomerSitState(entity: self),
            CustomerSitDownState(entity: self),
        ])
        
        let physicsComponent: PhysicsComponent = PhysicsComponent()
        physicsComponent.shape = PhysicsShape.rect.rawValue
        physicsComponent.category = PhysicsCategory.customer.rawValue
        
        let agentComponent = AgentComponent(scene: scene)
        let rulesComponent: RulesComponent = RulesComponent()
        
        // Enables working with scene items such as doors
        let sceneComponent = SceneComponent()
        let debugComponent = DebugComponent()
        
        addComponents([renderComponent, rulesComponent, orientationComponent, animationComponent, physicsComponent, agentComponent, intelligenceComponent, sceneComponent, debugComponent])
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Life cycle
    // -----------------------------------------------------------------
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        // Generate a debug info if enabled
        if GameplayConfiguration.Debug.enableInformation, let debug: DebugComponent = component(ofType: DebugComponent.self), let mandate = currentMandate {
            
            // Update the debug text if they don't match
            if debug.debugText != mandate.debugDescription {
                debug.debugText = mandate.debugDescription
            }
        }
        
        rulesComponent.updateState(deltaTime: seconds)
        
        return
    }
    
    // Remove pad after NPC is no longer using it
    func clearPad() {
        
        // Check mandate
        if case .consumeSitting = currentMandate, let node = interactingWithPad {
            
            // Clear the currently known node from unavailablePads
            InteractionPadComponent.unavailablePads.remove(node)
            
            // Remove character bots reference
            self.interactingWithPad = nil
        }
    }
    
    /// Quickly check the intelligence component state machine
    func isStateMachine(state: MachineStates) -> Bool {
        
        switch state {
        case .walkState:
            return intelligenceComponent.stateMachine.currentState is CustomerWalkState
        case .idleState:
            return intelligenceComponent.stateMachine.currentState is CustomerIdleState
        case .servedState:
            return intelligenceComponent.stateMachine.currentState is CustomerServedState
        case .sitState:
            return intelligenceComponent.stateMachine.currentState is CustomerSitState
        case .sitDownState:
            return intelligenceComponent.stateMachine.currentState is CustomerSitDownState
        }
    }
    
    /// Quickly update the intelligence component state machine
    func updateStateMachine(state: MachineStates) {
        
        switch state {
        case .walkState:
            intelligenceComponent.stateMachine.enter(CustomerWalkState.self)
        case .idleState:
            intelligenceComponent.stateMachine.enter(CustomerIdleState.self)
        case .servedState:
            intelligenceComponent.stateMachine.enter(CustomerServedState.self)
        case .sitState:
            intelligenceComponent.stateMachine.enter(CustomerSitState.self)
        case .sitDownState:
            intelligenceComponent.stateMachine.enter(CustomerSitDownState.self)
        }
    }
    
    /// Quickly check the intelligence component state machine
    func currentStateMachine() -> MachineStates? {
        
        switch intelligenceComponent.stateMachine.currentState {
        case is CustomerWalkState:
            return .walkState
        case is CustomerIdleState:
            return .idleState
        case is CustomerServedState:
            return .servedState
        case is CustomerSitState:
            return .sitState
        case is CustomerSitDownState:
            return .sitDownState
        default:
            return nil
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Update CharacterBot
    // -----------------------------------------------------------------
    
    // Sets the CharacterBot's orientation to match the GKAgent rotation.
    func updateBotsRotationToMatchAgents(agent: GKAgent2D) {
        animationComponent.updateAnimationByAgent(newState: .walkForward, agent: agent)
    }
}

extension CharacterBot: GKAgentDelegate {
    
    
    // -----------------------------------------------------------------
    // MARK: - Customer Mandate Delegate
    // -----------------------------------------------------------------
    
    /// Use for extracting node destination and availability
    func mandateDestination<T: SKNode>(node: FurnitureType, verifyAvailability: Bool) throws -> T? {

        // Scan level using node path
        guard let filteredNodes: [SKNode] = componentNode.scene?.filteredNodes(path: GameNodes.pathTo(node: node)) else {
            throw GameErrors.missingResource
        }
   
        // Check availablity of destination if requested
        if verifyAvailability {
            
            // Find all pads groups from all node names
            let pads: [InteractionPadComponent.Pad] = filteredNodes.map({$0.interactionPadComponent()}).map({$0?.generatedPads ?? []}).reduce([], +)
            
            // Find an available pads
            if let padItem = pads.map({$0.node}).filter({InteractionPadComponent.unavailablePads.contains($0) == false}).randomElement() {
                
                // Mark pad as unavailable
                InteractionPadComponent.unavailablePads.insert(padItem)
                
                // Cache pad
                self.interactingWithPad = padItem
                
                return padItem as? T
            } else {
                return nil
            }
        } else {
            
            // Scan level using node path
            guard let selectedNode = filteredNodes.randomElement() else {
                throw GameErrors.missingResource
            }
             
            // Check node for interaction component, else use node its self
            if let pad = selectedNode.interactionPadComponent()?.generatedPads.randomElement()?.node {
                return pad as? T
            } else {
                return selectedNode as? T
            }
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Agent Delegate
    // -----------------------------------------------------------------
    
    public func agentWillUpdate(_ agent: GKAgent) {

        // Fetch the entities sprite and check the agent is 2D and is processing movement actions
        guard let agent2d: GKAgent2D = agent as? GKAgent2D, self.agentComponent.isActive else {
            return
        }

        // Update the agent position to match the node position
        agent2d.position = vector_float2(Float(componentNode.position.x),
                                         Float(componentNode.position.y))
        
        agent2d.rotation = Float(orientationComponent.zRotation)
    }

    
    public func agentDidUpdate(_ value: GKAgent) {
    
        // Fetch the entities sprite and check the agent is 2D and is processing movement actions
        guard let agent2d: GKAgent2D = value as? GKAgent2D, self.agentComponent.isActive else {
            return
        }
 
        // Update the node position to match the agent position
        componentNode.position = CGPoint(x: CGFloat(agent2d.position.x),
                                         y: CGFloat(agent2d.position.y))
        
        updateBotsRotationToMatchAgents(agent: agent2d)
    }
}

