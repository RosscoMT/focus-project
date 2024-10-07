//
//  EntityDelegate.swift
//  
//
//  Created by Ross Viviani on 11/04/2023.
//

import GameplayKit

public protocol EntityDelegate: AnyObject {
    func navigationPath(name: String) -> (graph: GKGraph, data: NavigationGraphPaths)?
    func obstacles<T>(attributes: T)  -> NodeNavigation.GraphObstacles
    func nodesOnPathway(start: CGPoint, sprite: SKNode, destination: SKNode) -> NodeNavigation.GraphObstacles
    func navigationGraph() -> GKObstacleGraph<GKGraphNode2D>
    func removeEntity(entity: GKEntity)
    func focusCamera(sprite: SKNode?, point: CGPoint)
    func flushScene(sprite: SKNode)
    func markScene(a: CGPoint, b: CGPoint)
}
