//
//  NodeNavigation.swift
//  
//
//  Created by Ross Viviani on 29/04/2023.
//

import GameplayKit
import SpriteKit

public struct NodeNavigation {
    
    
    // -----------------------------------------------------------------
    // MARK: - Data models
    // -----------------------------------------------------------------
    
    public struct GraphObstacles {
        public let ignore: [GKPolygonObstacle]
        public let obstacles: [GKPolygonObstacle]
        
        public init(ignore: [GKPolygonObstacle], obstacles: [GKPolygonObstacle]) {
            self.ignore = ignore
            self.obstacles = obstacles
        }
    }
    
    public struct PointsModel {
        public let startPoint: GKGraphNode2D
        public let endPoint: GKGraphNode2D
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Navigation
    // -----------------------------------------------------------------
    
    // Try and plot a path for the NPC
    public static func plotPath(startPoint: SIMD2<Float>, endPoint: SIMD2<Float>, ignoreObstacles: [GKPolygonObstacle], pathRadius: Float, graph: GKObstacleGraph<GKGraphNode2D>) throws -> (path: GKPath, debugPoints: [CGPoint]) {
        
        // Connect the start and end positions to the scenes graph
        let connectedNodes = NodeNavigation.connectNodesToGraph(startPoint: startPoint,
                                                                endPoint: endPoint,
                                                                graph: graph,
                                                                ignoreObstacleRadius: ignoreObstacles)
        
        // Find a path between these two nodes and a valid paths can not be created if fewer than 2 path nodes were found, return.
        guard let pathNodes: [GKGraphNode2D] = graph.findPath(from: connectedNodes.startPoint, to: connectedNodes.endPoint) as? [GKGraphNode2D] else {
            throw GameErrors.pathFailed
        }
        
        // Return back path or specific error
        switch pathNodes.count {
        case 0:
            throw GameErrors.badPathDestination
        case 1:
            throw GameErrors.noPathFound
        default:
            
            // Create a new GKPath from the found nodes with the requested path radius.
            let path: GKPath = GKPath(graphNodes: pathNodes, radius: pathRadius)
            
            // Convert the GKGraphNode2D nodes into CGPoint`s for debug drawing.
            let pathPoints: [CGPoint] = pathNodes.map { CGPoint($0.position) }
            
            // Remove the "start" and "end" nodes when exiting this scope.
            defer {
                graph.remove([connectedNodes.startPoint, connectedNodes.endPoint])
            }
            
            return (path, pathPoints)
        }
    }
    
    /// Add the start and end points of a path to a scenes graph
    public static func connectNodesToGraph(startPoint: SIMD2<Float>, endPoint: SIMD2<Float>, graph: GKObstacleGraph<GKGraphNode2D>, ignoreObstacleRadius: [GKPolygonObstacle] = []) -> PointsModel {
        
        let startNode: GKGraphNode2D = GKGraphNode2D(point: startPoint)
        graph.connectUsingObstacles(node: startNode,
                                    ignoringBufferRadiusOf: ignoreObstacleRadius)
        
        let endNode: GKGraphNode2D = GKGraphNode2D(point: endPoint)
        graph.connectUsingObstacles(node: endNode,
                                    ignoringBufferRadiusOf: ignoreObstacleRadius)
        
        return .init(startPoint: startNode, endPoint: endNode)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    /// Filter node collection by name
    public static func filterObstacles<T: Collection<SKNode>>(nodes: T?, byName filter: [String]) -> [SKNode] {
        return nodes?.filter({filter.contains($0.name ?? "") == true}) ?? []
    }
    
    /// Generate the separate polygon obstacles for both ignored obstacles and required obstacles
    public static func generatePolygonObstacle(ignoreNodes: Set<SKNode>, obstacles: [SKNode]) -> GraphObstacles {
        
        // Use Set for the nodes which need to be ignored, to prevent additional adding
        let currentObstacleArray: [SKNode] = obstacles.filter({ignoreNodes.contains($0) == false})
        
        // Generate the GKPolygonObstacle from the filtered nodes
        return .init(ignore: SKNode.obstacles(fromNodePhysicsBodies: Array(ignoreNodes)), obstacles: SKNode.obstacles(fromNodePhysicsBodies: currentObstacleArray))
    }
    
    /// Gather any nodes that surround the destination node
    public static func nearbyNodes(sprite: SKNode, nodes: [SKNode]) -> [SKNode] {
        
        // Nodes that will be filtered
        var filterNodes: [SKNode] = []
        
        // Generate rect using computed size, origin values and pathway obstacles margin
        var zone = CGRect(origin: .zero, size: .init(width: sprite.frame.width + 100, height: sprite.frame.height + 100))
        
        // Centre the zone
        zone.origin = sprite.centrePoint()
        filterNodes.append(contentsOf: nodes.filter({$0.frame.intersects(zone)}))
        
        return filterNodes
    }

    /// Calculate area to cover from the start to end pathway
    public static func generateArea(start: CGPoint, end: CGPoint, margin: Double) -> CGRect {
        return CGRect(x: (start.x < end.x ? start.x : end.x) - margin, y: (start.y < end.y ? start.y : end.y) - margin, width: (start.x < end.x ? end.x - start.x : start.x - end.x) + margin, height: (start.y < end.y ? end.y - start.y : start.y - end.y) + margin)
    }
    
    /// Calculate the angle between two points
    public static func destinationAngle(valueOne: CGPoint, valueTwo: CGPoint) -> Double {
        
        let deltaX: Double = Double(valueTwo.x - valueOne.x)
        let deltaY: Double = Double(valueTwo.y - valueOne.y)
        
        return atan2(deltaY, deltaX)
    }
}
