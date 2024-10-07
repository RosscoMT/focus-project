//
//  LevelScene+GamePlay.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 20/07/2023.
//

import GameplayKit
import Engine

extension LevelScene: EntityDelegate {
    
    typealias GraphObstacles = NodeNavigation.GraphObstacles
    
    
    // -----------------------------------------------------------------
    // MARK: - EntityDelegate methods
    // -----------------------------------------------------------------
    
    // Return navigation path by name
    func navigationPath(name: String) -> (graph: GKGraph, data: NavigationGraphPaths)? {
        
        // Extract graph and configuaration from SKScene and levels configuration
        guard let sceneGraph: GKGraph = graphs[name], let configuration: NavigationGraphPaths = levelConfiguration.navigationGraphPaths.first(where: {$0.name.localizedCaseInsensitiveContains(name)}) else {
            assertionFailure("Unable to find navigation path data")
            return nil
        }
        
        return (sceneGraph, configuration)
    }
    
    // Return the navigation graph
    func navigationGraph() -> GKObstacleGraph<GKGraphNode2D> {
        return self.graph
    }
    
    func removeEntity(entity: GKEntity) {
        self.entities.remove(entity)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Obstacle
    // -----------------------------------------------------------------
    
    // Generate rect to capture all obstacles in path to destination
    func obstacles<T>(attributes: T) -> GraphObstacles {
        
        guard let data = attributes as? LevelScene.ObstaclesData else {
            fatalError()
        }
        
        // Clear graph before rebuilding obstacle list
        self.graph.removeAllObstacles()
        
        // Nodes that will be filtered
        var filterNodes: [SKNode] = NodeNavigation.filterObstacles(nodes: model.furniture, byName: data.filter)
        filterNodes.append(data.destination)
        
        // Filter nodes on the path to destination
        filterNodes.append(contentsOf: NodeNavigation.nearbyNodes(sprite: data.sprite, nodes: model.furniture))
        filterNodes.append(contentsOf: NodeNavigation.nearbyNodes(sprite: data.destination, nodes: model.furniture))
        
        // Sort obstacle data
        let obstacleData: GraphObstacles = NodeNavigation.generatePolygonObstacle(ignoreNodes: Set(filterNodes), obstacles: self.scenesObstacles)
        
        // Add the obsticals to the graph
        self.graph.addObstacles([obstacleData.ignore, obstacleData.obstacles].reduce([], +))
        
        return obstacleData
    }
    
    // Generate rect to capture all obstacles in path to destination
    func nodesOnPathway(start: CGPoint, sprite: SKNode, destination: SKNode) -> GraphObstacles {
        
        // Clear graph before rebuilding obstacle list
        self.graph.removeAllObstacles()
        
        // Generate rect using computed size, origin values and pathway obstacles margin
        let rect = NodeNavigation.generateArea(start: start, end: destination.position, margin: config.pathwayObstaclesMargin)
        
        // Nodes that will be filtered
        var filterNodes: [SKNode] = NodeNavigation.nearbyNodes(sprite: destination, nodes: model.furniture)
        filterNodes.append(contentsOf: model.furniture.filter({$0.frame.intersects(rect)}))
        filterNodes.append(contentsOf: NodeNavigation.nearbyNodes(sprite: sprite, nodes: model.furniture))
        
        // Sort obstacle data
        let obstacleData = NodeNavigation.generatePolygonObstacle(ignoreNodes: Set(filterNodes), obstacles: self.scenesObstacles)
        
        // Add the obsticals to the graph
        self.graph.addObstacles([obstacleData.ignore, obstacleData.obstacles].reduce([], +))
        
        return obstacleData
    }
    
    // -----------------------------------------------------------------
    // MARK: - State methods
    // -----------------------------------------------------------------
    
    /// Reposition a furniture item within the scene, considering also other furniture items
    func repositionFurnitureNode(with event: GameEvent) async {
        
        guard let selectedNode = model.selectedNode else {
            return
        }
        
        // Quick access to the components of the furniture item entity
        let components = Furniture.extractComponent(node: selectedNode)
        
        // The calculated next position returning a point
        let calculatedPosition: CGPoint = GeneralTools.snapToPoint(step: config.snapMeasurement, position: event.data.location(in: self))
       
        // Create a test node to check the next position is feasible
        let bufferNode: SKNode = BoundaryComponent.generateNodeWithBoundaryBox(node: selectedNode, position: calculatedPosition)
        
        // Build an array of nodes we want to check
        let nodeTestArray = excludeFurniture()
        
        // Stop the user trying to move an item out of the indoor area ie board
        guard self.nodes(at: calculatedPosition).contains(GameNodes.board) else {
            return
        }
        
        // Check the calculatedPosition and run the bufferNode against the node list we don't want to intersect
        let intersects: Bool = nodeTestArray.intersectsNode(node: bufferNode)
        
        // Generate the actions for movement
        let moveAction: SKAction = .move(to: calculatedPosition, duration: config.snapMovementDelay)
        
        // Update the interacting pads positions
        let updateInteractionpads = SKAction.run {
            components.interactionPadComponent.generatedPads.forEach({components.interactionPadComponent.zonePosition(position: $0.direction, node: $0.node)})
        }
        
        // Build a list of actions for this move
        var actions: [SKAction] = []
        
        // If the entity is intersecting and the boundry box value is incorrect run action code to revise the current known information
        if intersects == true && components.boundryComponent.intersecting == false {
            recolourBoundryBox(actions: &actions, boundryComponent: components.boundryComponent, value: true)
        }
        
        // If the entity is no longer intersecting and the boundry box value is incorrect run action code to revise the current known information
        if intersects == false && components.boundryComponent.intersecting == true {
            recolourBoundryBox(actions: &actions, boundryComponent: components.boundryComponent, value: false)
        }
        
        // Add the movement actions to the current set
        actions.append(contentsOf: [moveAction, updateInteractionpads])
        
        // Cache the selected nodes last position
        model.selectedNodeLastPosition = selectedNode.position
        
        // Run animation sequence
        await model.selectedNode?.run(.sequence(actions))
    }
    
    
    /// Used to construct the array of furniture to avoid when moving or adding to the scene
    /// - Returns: The array of furniture, minus the furniture node being positioned
    func excludeFurniture() -> Set<SKNode> {
        
        guard let selectedNode = model.selectedNode else {
            fatalError("No selected node")
        }
        
        var array = Set([model.wall, model.furniture].reduce([], +))
        array.remove(selectedNode)
        
        return array
    }
    
    /// Quickly re-colours the boundary box
    /// - Parameters:
    ///   - actions: The action list that will be used with this boundary box node
    ///   - boundryComponent: The boundary box component
    ///   - value: The state that the boundary box should be changed to
    fileprivate func recolourBoundryBox(actions: inout [SKAction], boundryComponent: BoundaryComponent, value: Bool) {
        actions.append(.run {
            boundryComponent.recolourBoundryBox(value)
        })
    }
}
