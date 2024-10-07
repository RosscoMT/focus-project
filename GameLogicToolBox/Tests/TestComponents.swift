//
//  TestComponents.swift
//  
//
//  Created by Ross Viviani on 30/04/2023.
//

import XCTest
import GameplayKit
import Foundation
import Engine

@testable import Engine

final class TestComponents: XCTestCase {
    
    let start: SIMD2<Float> = .zero
    let end: SIMD2<Float> = .init(x: 1000, y: 1000)
    
    // Test that the path should be successfully calculated
    func testPlotPath() {
        
        let obstacles = SKShapeNode(rect: .init(origin: .init(x: 500, y: 500), size: .init(width: 50, height: 50)))
        
        let obstacleGraph = GKObstacleGraph(obstacles: SKNode.obstacles(fromNodeBounds: [obstacles]), bufferRadius: 10)
        
        do {
            let sut = try NodeNavigation.plotPath(startPoint: start,
                                                  endPoint: end,
                                                  ignoreObstacles: [], pathRadius: 10,
                                                  graph: obstacleGraph)
            
            XCTAssertNotNil(sut.path)
            XCTAssertEqual(sut.debugPoints.isEmpty, false)
        } catch {
            XCTFail("Failed to find path")
        }
    }
    
    // Test that the path should fail if there is an obstacle
    func testBadPlotPath() {
        
        let obstacles = SKShapeNode(rect: .init(origin: .zero, size: .init(width: 50, height: 50)))
        
        let obstacleGraph = GKObstacleGraph(obstacles: SKNode.obstacles(fromNodeBounds: [obstacles]), bufferRadius: 10)
        
        do {
            let _ = try NodeNavigation.plotPath(startPoint: start,
                                        endPoint: end,
                                        ignoreObstacles: [], pathRadius: 10,
                                        graph: obstacleGraph)
        } catch {
            XCTAssertEqual(error as! GameErrors, GameErrors.noPathFound)
        }
    }
    
    func testConnectNodesToGraph() {
        
        // Setup text conditions
        let obstacleGraph = GKObstacleGraph(obstacles: [], bufferRadius: 10)
        
        let sut = NodeNavigation.connectNodesToGraph(startPoint: start, endPoint: end, graph: obstacleGraph)
       
        // Check that nodes were correctly added
        XCTAssertEqual(obstacleGraph.nodes?.count, 2)
        XCTAssertEqual(obstacleGraph.nodes?.contains(sut.startPoint), true)
        XCTAssertEqual(obstacleGraph.nodes?.contains(sut.endPoint), true)
        
        XCTAssertEqual(obstacleGraph.nodes?.contains(where: {($0 as? GKGraphNode2D)?.position == .zero}), true)
        XCTAssertEqual(obstacleGraph.nodes?.contains(where: {($0 as? GKGraphNode2D)?.position == .init(x: 1000, y: 1000)}), true)
        
        obstacleGraph.remove([sut.startPoint, sut.endPoint])
        
        // Check that nodes were correctly removed
        XCTAssertEqual(obstacleGraph.nodes?.count, 0)
        XCTAssertEqual(obstacleGraph.nodes?.contains(sut.startPoint), false)
        XCTAssertEqual(obstacleGraph.nodes?.contains(sut.endPoint), false)
        
        XCTAssertEqual(obstacleGraph.nodes?.contains(where: {($0 as? GKGraphNode2D)?.position == .zero}), false)
        XCTAssertEqual(obstacleGraph.nodes?.contains(where: {($0 as? GKGraphNode2D)?.position == .init(x: 1000, y: 1000)}), false)
    }
}
