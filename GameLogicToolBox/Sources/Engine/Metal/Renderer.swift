//
//  Renderer.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 24/08/2024.
//

import MetalKit
import SpriteKit

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public protocol RendererLevelUpdate {
    func updateScene(current: TimeInterval)
    func didFinishUpdate()
    func didEvaluateActions()
    func didSimulatePhysics()
}

public struct CameraCoordinates {
    public var x: CGFloat = 0.5
    public var y: CGFloat = 0.5
    public var scale: CGFloat = 0
    
    func position() -> CGPoint {
        return .init(x: x, y: y)
    }
}

open class Renderer: NSObject {
    static public var device: MTLDevice!
    static public var commandQueue: MTLCommandQueue!
    static public var commandBuffer: MTLCommandBuffer?
    static public var library: MTLLibrary!
    static public var colorPixelFormat: MTLPixelFormat!
    static public var renderPassDescriptor: MTLRenderPassDescriptor?
    static public var fps: Int!
    
    static public var size: CGSize = .zero
    static public var metalView: GameMetalView?
    static public var scene: SKScene?
    static public var skRenderer: SKRenderer?
    static public var cameraCoordinates: CameraCoordinates = .init()
    static public var cameraMove: Bool = false
    
    public init(metalView: GameMetalView) {
        
        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        
        Self.device = device
        Self.commandQueue = commandQueue
        Self.library = device.makeDefaultLibrary()
        Self.colorPixelFormat = metalView.colorPixelFormat
        Self.fps = metalView.preferredFramesPerSecond
        
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.framebufferOnly = false
        metalView.becomeFirstResponder()
    
        Self.size = metalView.bounds.size
        Self.metalView = metalView
        Self.skRenderer = SKRenderer(device: device)
        
        super.init()
        metalView.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
}

extension Renderer: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Self.scene?.size = size
    }

    public func draw(in view: MTKView) {
        
        #warning("2: The current implementation of SKRenderer")
        
        // Ensure the scene is of the correct type and that essential objects are available
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = Renderer.commandQueue.makeCommandBuffer(), let size = Self.scene?.size else {
            return
        }
        
        // Assign command buffer and descriptor for use later in rendering
        Renderer.commandBuffer = commandBuffer
        Renderer.renderPassDescriptor = descriptor
        
        // Calculate deltaTime
        let currentTime = CACurrentMediaTime()
        
        // Synchronize SKRenderer with the current time
        Self.skRenderer?.update(atTime: currentTime)
        Self.scene?.didSimulatePhysics()   // Simulate physics
        Self.scene?.didEvaluateActions()   // Evaluate actions
        Self.scene?.didFinishUpdate()      // Finalize updates
  
        // Render the scene using SKRenderer
        let viewPort = CGRect(origin: .zero, size: size)
        Self.skRenderer?.render(withViewport: viewPort,
                           commandBuffer: commandBuffer,
                           renderPassDescriptor: descriptor)
        
        // Present the current drawable and commit the command buffer
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        // Optionally wait for the rendering to finish (can be removed for non-blocking rendering)
        commandBuffer.waitUntilCompleted()
    }
    
    func runAction() {
        Self.scene?.camera?.run(.moveBy(x: 200, y: 300, duration: 4))
        Renderer.cameraMove = false
    }
    
    func updateCamera() {
        Self.scene?.camera?.position = Self.cameraCoordinates.position()
    }
}

public extension Renderer {
    
    static func presentScene(with scene: SKScene) {
        Self.scene = scene
        Self.skRenderer?.scene = scene
    }

    // You will need to find the origin point for the metal view as it will not be zero ie it is drifting in the much larger levelscene. If you can find the metal origin then the
//    static func translatePointToSystem2(point: CGPoint) -> CGPoint {
//        // Define scaling factors
//        let scaleX: CGFloat = 2272 / 868
//        let scaleY: CGFloat = 1449 / 593
//        
//        // Apply scaling
//        let newX = point.x * scaleX
//        let newY = point.y * scaleY
//        
//        // Adjust based on the new origin of system 2
//        let translatedX = newX + originSystem2.x
//        let translatedY = newY + originSystem2.y
//        
//        return CGPoint(x: newX, y: newY)
//    }

    
    /* Look to using a manual approach such as the function below to handle the conversion of the coordinate systems, the convertTo(from:) is broken between metal view and spritekit. As Spritekit requires the SKView to properly operate*/
    
    
    // Function to convert point from Metal view (MTKView) coordinate system to SpriteKit's SKScene coordinate system
    static func transformPoint(from sourcePoint: CGPoint,
                               in mtkView: MTKView,
                               to targetNode: SKSpriteNode,
                               zoom: CGPoint) -> CGPoint {
        
        // Get the size (bounds) of the MTKView and SKSpriteNode
        let metalView = mtkView.bounds.size
        let node = targetNode.size
        
        // Scale the source point according to the contentsScale (Retina adjustment)
        let scaledSourcePoint = CGPoint(x: sourcePoint.x,
                                        y: sourcePoint.y)
        
        // Calculate the scaling factors between MTKView and SKSpriteNode
        let scaleX = node.width / metalView.width
        let scaleY = node.height / metalView.height

        // Apply scaling to transform the point
        let scaledX = scaledSourcePoint.x * scaleX
        let scaledY = scaledSourcePoint.y * scaleY
      
        return CGPoint(x: scaledX, y: scaledY)
    }
    
//    static func translatePointWithCamera(point: CGPoint, camera: SKCameraNode) -> CGPoint {
//        // Get the camera position and scaling factors (zoom levels)
//        let cameraPosition = camera.position
//        let xScale = camera.xScale
//        let yScale = camera.yScale
//        
//        // Translate the point based on the camera's position
//        let translatedX = (point.x - cameraPosition.x) / xScale
//        let translatedY = (point.y - cameraPosition.y) / yScale
//        
//        return CGPoint(x: translatedX, y: translatedY)
//    }
    
    static func transformPoint(from sourcePoint: CGPoint,
                               in mtkView: MTKView,
                               to targetNode: SKSpriteNode,
                               camera: SKCameraNode) -> CGPoint {
        
        // Get the size (bounds) of the MTKView and SKSpriteNode
        let metalViewSize = mtkView.bounds.size
        let nodeSize = targetNode.size
        
        // Scale the source point according to the contentsScale (Retina adjustment)
        let scaledSourcePoint = CGPoint(x: sourcePoint.x,
                                        y: sourcePoint.y)
        
        // Calculate the scaling factors between MTKView and SKSpriteNode
        let scaleX = nodeSize.width / metalViewSize.width
        let scaleY = nodeSize.height / metalViewSize.height
        
        // Apply scaling to transform the point
        let transformedX = scaledSourcePoint.x * scaleX
        let transformedY = scaledSourcePoint.y * scaleY
        
        // Get the camera's position and zoom factors (xScale and yScale)
        let cameraPosition = camera.position
        var xScale = camera.xScale
        var yScale = camera.yScale
        
        xScale.negate()
        yScale.negate()
        
        // Apply the camera's translation and zoom (inversely scaled)
        let finalX = (transformedX - cameraPosition.x)
        let finalY = (transformedY - cameraPosition.y)
        
        return CGPoint(x: transformedX, y: transformedY)
    }

}
