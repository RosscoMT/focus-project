//
//  DebugTools.swift
//  
//
//  Created by Ross Viviani on 20/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import MetalKit

/// A set of tools which can help in a range of issues
public struct DebugTools {
    
    // Debug timer
    static var timer: Timer?
    public static let colour: [SKColor] = [.blue, .black, .cyan, .green, .red, .yellow, .orange, .purple, .brown]
    
    // -----------------------------------------------------------------
    // MARK: - General
    // -----------------------------------------------------------------
    
    static public func timeStamp() {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss.SSSS"
        print(dateFormatter.string(from: Date()))
    }
    
    static public func startStopWatch() {
        
        var counter: Double = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            counter += 0.1
            print(counter)
        }
    }
    
    static public func stopStopWatch() {
        timer?.invalidate()
    }
    
    // -----------------------------------------------------------------
    // MARK: - Pathfinding
    // -----------------------------------------------------------------
    
    static public func displayBotPath(name: String, points: [CGPoint], scene: SKScene?) {
        
        // Remove any previous debug debug points
        clearDebugNode(name: name, scene: scene)
        
        guard let currentScene: SKScene = scene else {
            return
        }
        
        // Add debug layer if not setup
        if currentScene.childNode(withName: "DebugLayer") == nil {
            let debugLayer = SKShapeNode(rect: currentScene.frame)
            debugLayer.position = currentScene.position
            debugLayer.zPosition = scene?.zPosition ?? 0
            debugLayer.name = "DebugLayer"
            currentScene.addChild(debugLayer)
        }
        
        // The draw count is climbing too fast as paths are being plotted by bots moving about
        let colour: SKColor = DebugTools.colour.randomElement()!
        let debugLayer = currentScene.childNode(withName: "DebugLayer")!
        
        // Use a index to extract each point
        for index in 0..<points.count {
            
            // Draw line highlighting the path the NPC will move
            if index < points.count - 1 {
                let lineNode = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: points[index])
                path.addLine(to: points[index + 1])
                lineNode.name = name
                lineNode.path = path
                lineNode.strokeColor = colour
                lineNode.lineWidth = 1
                lineNode.zPosition = scene?.zPosition ?? 0
                debugLayer.addChild(lineNode)
            }
        }
        
        return
    }
    
    // Print obstacle information
    static public func debugObstacleInformation<T: Collection, O: Collection, X: Collection>(ignoreNodes: T, obstacles: O, total: X) {
        print("Ignore \(ignoreNodes.count)")
        print("ObstaclesArray \(obstacles.count)")
        print("Total \(total.count)")
    }
    
    /// Remove the debug nodes
    static public func clearDebugNode(name: String, scene: SKScene?) {
        
        var nodesArray: [SKNode] = []
        
        if let debugLayer = scene?.childNode(withName: "DebugLayer") {
            
            // Filter scenes child nodes for debug points
            debugLayer.enumerateChildNodes(withName: name, using: { node, stop in
                
                if node.name?.contains(name) == true {
                    nodesArray.append(node)
                }
            })
            
            // Remove all filtered nodes
            nodesArray.forEach({$0.removeFromParent()})
        }
    }
    
    /// Add mark to scene to allow for path discovery
    static public func markScene(a: CGPoint, b: CGPoint, scene: SKScene, zPosition: CGFloat) {
        
        // Marks the start point
        let aPoint: SKShapeNode = SKShapeNode(rect: .init(origin: .zero, size: .init(width: 10, height: 10)))
        aPoint.position = a
        aPoint.fillColor = .green
        aPoint.zPosition = zPosition
        
        // Marks end point
        let bPoint: SKShapeNode = SKShapeNode(rect: .init(origin: .zero, size: .init(width: 10, height: 10)))
        bPoint.position = b
        bPoint.fillColor = .red
        bPoint.zPosition = zPosition
       
        scene.addChilds([aPoint, bPoint])
    }
    

}

extension SKSpriteNode {
    
    /// Add mark to scene to allow for path discovery
    public func markSprite() {
        self.run(.colorize(with: .blue, colorBlendFactor: 0.5, duration: 0))
    }
}

public extension SKScene {
    
    private func calculate(valueOne: Double, valueTwo: Double) -> Double {
        switch valueOne {
        case let point where point > valueTwo:
            return point - valueTwo
        case let point where point < valueTwo:
            return valueTwo - point
        default:
            return .zero
        }
    }
    
    func cameraOffset(metal: MTKView?, camera: SKCameraNode?) -> CGPoint {
        
        guard let metalView: MTKView = metal, let backgroundNode = self.childNode(withName: "//backgroundNode") else {
            fatalError("Game level is missing background node")
        }
        
        let currentCameraCenterPoint = backgroundNode.cameraCentrePoint(with: metalView, camera: camera)
        
        /* Example:
         - BackgroundNodeFrame: 1200 x 600
         - Metal view:          800 x 450
        
         - BackgroundNodeFrame  x: 600, y: 300
         - Metal view           x: 400, y: 225
         
         - BackgroundNodeFrame.x - Metal.x
         
        */
        
        guard let cameraPointX = currentCameraCenterPoint?.x, let cameraPointY = currentCameraCenterPoint?.y else {
            return .zero
        }
        
        // The backgrond nodes centre point
        let backgroundNodeX: Double = backgroundNode.centrePoint().x
        let backgroundNodeY: Double = backgroundNode.centrePoint().y
        
        // Where the cameras origin to the left hand side would be x: 0 and y: 0
        let resultX: Double = calculate(
            valueOne: cameraPointX,
            valueTwo: backgroundNodeX
        )
        
        let resultY: Double = calculate(
            valueOne: cameraPointY,
            valueTwo: backgroundNodeY
        )
        
        return .init(x: resultX, y: resultY)
    }
}

public extension SKNode {

    func cameraCentrePoint(with metal: MTKView?, camera: SKCameraNode?) -> CGPoint? {
        
        guard let metalView = metal, let cameraNode = camera else {
            return nil
        }
        
        return metalView.convert(cameraNode.position, to: metalView)
    }
    
    func markCameraCentrePoint(with metal: MTKView?, camera: SKCameraNode?) {
        
        guard let position = cameraCentrePoint(with: metal, camera: camera) else {
            return
        }
        
        let cameraCentrePoint = SKSpriteNode(
            color: .systemYellow,
            size: CGSize(
                width: 10,
                height: 10
            )
        )
        
        cameraCentrePoint.position = position
        cameraCentrePoint.zPosition = 10
        cameraCentrePoint.anchorPoint = .zero
        self.addChild(cameraCentrePoint)
    }
}
