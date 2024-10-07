//
//  AgentComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 05/04/2023.
//

import GameplayKit
import Engine

/// Adds a 2D agent to entities to allow for various movement behaviours
class AgentComponent: GKComponent {
    
    typealias vectorPoint = vector_float2
    typealias config = GameplayConfiguration.CharacterBot
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    let agent: GKAgent2D = GKAgent2D()
    var scene: LevelScene?
    
    // Entity attached to this component
    var agentEntity: FoundationEntity {
        return self.entity as! FoundationEntity
    }

    var currentTargetPosition: vectorPoint?
    var pathOrientation: NavigationGraphPaths.Orientation?
    
    // Holds references to the currently set goals
    var goals: Set<Goals> = [] {
        didSet {
            agent.speed = goals.contains(where: {$0.name == .stop}) ? 0 : 80
        }
    }
    
    // Reference to the bots current movement state
    var isActive: Bool {
        return goals.contains(where: {$0.name == .stop}) ? false : true
    }
    
    var currentMandate: CustomerMandate?
    var destinationPoint: CGPoint?

    
    // -----------------------------------------------------------------
    // MARK: - Initialisation
    // -----------------------------------------------------------------
    
    override func didAddToEntity() {
        
        var levelScene: LevelScene!
        
        // Attach the scene if attached by sks
        if let scene = componentNode.scene as? LevelScene {
            levelScene = scene
        }
        
        // Attach the scene if coded in
        if let scene = self.scene {
            levelScene = scene
        }
         
        // Setup the agent using componentNode and settings model
        agent.factoryAgent(entity: componentNode.entity, config: config.settingModel())
        
        // Add the agent component to the component system
        levelScene.agentComponentSystem.addComponent(agent)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Updating
    // -----------------------------------------------------------------

    func updateGoalsAndBehaviour(goals: [Goals]) {
        
        // Shift the character bots state to idle to suspend the animation
        self.entity?.component(ofType: IntelligenceComponent.self)?.stateMachine.enter(CustomerWalkState.self)
        
        self.goals = .init(goals)
        
        let goals: [(goal: GKGoal, weight: NSNumber)] = goals.map({($0.goal, $0.weight)})
        agent.updateBehaviour(goals: goals.map({$0.goal}), weights: goals.map({$0.weight}))
    }
 
    func stopCurrentBehaviour(_ setState: Bool = true) {
        
        // Shift the character bots state to idle to suspend the animation
        if setState {
            self.entity?.component(ofType: IntelligenceComponent.self)?.stateMachine.enter(CustomerIdleState.self)
        }
        
        // Clear any outstanding behaviours
        goals.removeAll()
        goals.insert(.init(name: .stop, goal: .init(toReachTargetSpeed: 0), weight: 10.0))
        
        let goals: [(goal: GKGoal, weight: NSNumber)] = goals.map({($0.goal, $0.weight)})
        agent.updateBehaviour(goals: goals.map({$0.goal}), weights: goals.map({$0.weight}))
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

extension AgentComponent {
    
    /// Mandate for bot setting up the behavior for the bot to enter scene
    func enterSceneMandate() {
        
        Task { [weak self] in
            
            // Fetch and unpack the navigation path data
            if let graphData = self?.agentEntity.delegate?.navigationPath(name: "EntrancePath"), let nodes: [GKGraphNode2D] = graphData.graph.nodes as? [GKGraphNode2D] {
                
                // Construct the path
                let path = GKPath(graphNodes: nodes, radius: 0)
                path.isCyclical = graphData.data.isCyclical
                
                // Store path data
                self?.currentTargetPosition = graphData.data.forwardDirection ? nodes.last?.position : nodes.first?.position
                self?.pathOrientation = graphData.data.orientation
                
                // Manually set the direction to face based on the paths direction
                if let orientation = self?.entity?.component(ofType: OrientationComponent.self) {
                    let direction: CompassDirection = graphData.data.forwardDirection ? .west : .east
                    orientation.zRotation = direction.degreesOfCompass()
                }
                
                // Move to destination
                if let destinationPoint = self?.currentTargetPosition?.point() {
                    await self?.componentNode.run(.sequence([.move(to: destinationPoint, duration: 2), .wait(forDuration: 0.2)]))
                } else {
                    fatalError("CurrentTargetPosition is missing")
                }
            } else {
                fatalError("Failed to find path")
            }
        }
    }
    
    func wander() {
        // Set a random direction
        self.entity?.component(ofType: OrientationComponent.self)?.newDirection()
        
        if let scene = componentNode.scene as? LevelScene {
            
            var obstacles: [SKNode] = scene.model.furniture
            obstacles.append(contentsOf: scene.model.wall)
            obstacles.append(contentsOf: scene.model.entryPoints)
            
            let nodeObstacles = SKNode.obstacles(fromNodeBounds: obstacles)

            // Centre scenes agent
            let centreSceneAgent: GKAgent2D = (componentNode.scene?.childNode(withName: "CentreScreenAgent")?.component(AgentComponent.self).agent)!
 
            // Set the goals with wander and avoid obstacles
            updateGoalsAndBehaviour(goals: [
                .init(name: .toWander, goal: .init(toWander: 80), weight: 50.0),
                .init(name: .toAvoid, goal: GKGoal(toAvoid: nodeObstacles, maxPredictionTime: TimeInterval(3)), weight: 1000.0),
                .init(name: .toReachTargetSpeed, goal: .init(toReachTargetSpeed: 100), weight: 50),
                .init(name: .toSeekAgent, goal: .init(toSeekAgent: centreSceneAgent), weight: 0.2)
            ])
        }
    }
}

extension AgentComponent {
    
    convenience init(scene: LevelScene) {
        self.init()
        self.scene = scene
    }
    
    /// This function encapsulates navigations mandates - ie require walking
    func navigateMandate(destination: SKNode, debugPoints: Bool) throws -> [Goals] {
        
        let data = LevelScene.ObstaclesData(start: agent.position.point(),
                                            destination: destination,
                                            sprite: componentNode,
                                            overlappingFiltering: true,
                                            filter: [])
        
        let navigationData: NavigateSpriteData = .init(destination: destination,
                                                       obstaclesInfo: agentEntity.delegate?.obstacles(attributes: data))
        
        do {
            
            // Try initial attempt to plot a path
            return try navigateSpriteTo(data: navigationData,
                                        pathRadius: GameplayConfiguration.Level.NPC.pathRadius) ?? []
        } catch {
            
            do {
                
                // Try alternative attempt to plot a path
                return try navigateSpriteTo(data: .init(destination: destination,
                                                        obstaclesInfo: agentEntity.delegate?.nodesOnPathway(start: agent.position.point(),
                                                                                                            sprite: componentNode,
                                                                                                            destination: destination)), pathRadius: GameplayConfiguration.Level.NPC.pathRadius) ?? []
            } catch {
                throw error
            }
        }
    }
    
    /// Attempt to generate a path and setup behaviours
    private func navigateSpriteTo(data: NavigateSpriteData, pathRadius: Float) throws -> [Goals]? {
        
        // Fetch current obstacles and interaction pad - (destination)
        guard let graph = agentEntity.delegate?.navigationGraph(), let obstaclesData = data.obstaclesInfo else {
            fatalError("Missing components")
        }
        
        // Attempt extract point of interaction pad else..
        let point: vectorPoint = vectorPoint.destinationMidPoint(data: data)
        
        do {
            
            // Try and plot a path to the destination
            let plottedPathData = try NodeNavigation.plotPath(startPoint: agent.position,
                                                              endPoint: point,
                                                              ignoreObstacles: obstaclesData.ignore,
                                                              pathRadius: pathRadius,
                                                              graph: graph)
            
            // Use the generated path
            let plottedPathGoals: [Goals] = [.init(name: .toFollow, goal: GKGoal(toFollow: plottedPathData.path, maxPredictionTime: 0.5, forward: true), weight: 1.0), .init(name: .toStayOn, goal: GKGoal(toStayOn: plottedPathData.path, maxPredictionTime: 0.5), weight: 5.0)]
            
            // Display debug information
            SceneManager.executeDebugRequests(type: .showPath, task: {
                
                DebugTools.displayBotPath(name: GKEntity.debugNodes(entity: agentEntity),
                                          points: plottedPathData.debugPoints,
                                          scene: entity?.component(ofType: RenderComponent.self)?.spriteNode?.scene)
            })
            
            return [plottedPathGoals, [Goals(name: .toReachTargetSpeed, goal: GKGoal(toReachTargetSpeed: agent.maxSpeed), weight: 1.5), Goals(name: .toAvoid, goal: GKGoal(toAvoid: obstaclesData.obstacles, maxPredictionTime: 0.7), weight: 1.1)]].reduce([], +)
        } catch {
            throw error
        }
    }
}

// -----------------------------------------------------------------
// MARK: - Component Specific Extensions
// -----------------------------------------------------------------

fileprivate extension vector_float2 {
    
    /// Extract destination node mid point
    static func destinationMidPoint(data: NavigateSpriteData) -> AgentComponent.vectorPoint {
        
        if data.destination.name?.contains("Zone") ?? false {
            return CGPoint(x: data.destination.frame.midX, y: data.destination.frame.midY).vectorFloatPoint()
        } else {
            return data.destination.centrePoint().vectorFloatPoint()
        }
    }
}
