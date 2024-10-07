//
//  SKCameraNode+Extension.swift
//  
//
//  Created by Ross Viviani on 04/01/2023.
//

import SpriteKit

public extension SKCameraNode {
    
    
    // -----------------------------------------------------------------
    // MARK: - Public Data models
    // -----------------------------------------------------------------
    
    struct SceneData {
        let board: SKNode
        let node: SKNode
        let size: CGSize
        
        public init(board: SKNode, node: SKNode, size: CGSize) {
            self.board = board
            self.node = node
            self.size = size
        }
    }
    
    struct Config {
        let cameraEdgeBounds: CGFloat
        
        public init(cameraEdgeBounds: CGFloat) {
            self.cameraEdgeBounds = cameraEdgeBounds
        }
    }
    
    // Convenience method for setting position and scale
    func positionWithScale(position: CGPoint, scale: CGFloat) {
        self.position = position
        self.setScale(scale)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Private methods
    // -----------------------------------------------------------------
    
    private func calculateConstraints(boardNode: SKNode, scaledSize: CGSize, locationConstraint: SKConstraint, config: Config) -> [SKConstraint] {
        
        // Calculate the accumulated frame of this node
        let boardContentRect: CGRect = boardNode.calculateAccumulatedFrame()
        
        // Work out how far within this rectangle to constrain the camera. We want to stop the camera when we get within 100pts of the edge of the screen, unless the level is so small that this inset would be outside of the level.
        let xInset: CGFloat = min((scaledSize.width / 2) - config.cameraEdgeBounds,
                                  boardContentRect.width / 2)
        
        let yInset: CGFloat = min((scaledSize.height / 2) - config.cameraEdgeBounds,
                                  boardContentRect.height / 2)
         
        // Use these insets to create a smaller inset rectangle within which the camera must stay.
        let insetContentRect: CGRect = boardContentRect.insetBy(dx: xInset, dy: yInset)
        
        // Define an `SKRange` for each of the x and y axes to stay within the inset rectangle.
        let xRange: SKRange = SKRange(lowerLimit: insetContentRect.minX,
                                      upperLimit: insetContentRect.maxX)
        
        let yRange: SKRange = SKRange(lowerLimit: insetContentRect.minY,
                                      upperLimit: insetContentRect.maxY)
        
        // Constrain the camera within the inset rectangle.
        let levelEdgeConstraint: SKConstraint = SKConstraint.positionX(xRange, y: yRange)
        levelEdgeConstraint.referenceNode = boardNode
        
        return [locationConstraint, levelEdgeConstraint]
    }

    
    // -----------------------------------------------------------------
    // MARK: - Public methods
    // -----------------------------------------------------------------
    
    func setCameraConstraints(data: SceneData, config: Config) {
   
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange: SKRange = SKRange(constantValue: 0.0)
        
        // Also constrain the camera to avoid it moving to the very edges of the scene. First, work out the scaled size of the scene. Its scaled height will always be the original height of the scene, but its scaled width will vary based on the window's current aspect ratio.
        let scaledSize: CGSize = CGSize(width: data.size.width * self.xScale,
                                        height: data.size.height * self.yScale)
       
        // Calculate constraints
        let constraints: [SKConstraint] = calculateConstraints(boardNode: data.board,
                                                               scaledSize: scaledSize,
                                                               locationConstraint: SKConstraint.distance(zeroRange, to: data.node),
                                                               config: config)
        
        // Assign constraints
        self.constraints = constraints
    }
    
    #if os(macOS)
    
    // Return nodes at event location
    func nodesAtEventLocation(_ event: GameEvent) -> [SKNode] {
        let position: CGPoint = event.data.location(in: self)
        return self.nodes(at: position)
    }
    
    #elseif os(iOS)
    
    // Return nodes at event location
    func nodesAtEventLocation(_ event: UITouch) -> [SKNode] {
        let position: CGPoint = event.location(in: self)
        return self.nodes(at: position)
    }
    
    #endif
}

