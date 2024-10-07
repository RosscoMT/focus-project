//
//  TouchControlInputNode.swift
//
//
//  Created by Ross Viviani on 12/10/2022.
//

import SpriteKit

#if os(iOS) || os(tvOS)

// Configuration settings for the thumb sticks
public struct TouchControlConfiguration {
    let thumbStickNodeSize: CGSize
    let minimumRequiredThumbstickDisplacement: Float
    
    public init(_ thumbStickNodeSize: CGSize, _ minimumRequiredThumbstickDisplacement: Float) {
        self.thumbStickNodeSize = thumbStickNodeSize
        self.minimumRequiredThumbstickDisplacement = minimumRequiredThumbstickDisplacement
    }
}

/// An implementation of the `GenericInputSourceDelegate` protocol that enables support for touch-based thumbsticks on iOS.
public class TouchControlInputSource: SKSpriteNode, GenericInputSourceDelegate {
    

    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // `GenericInputSourceDelegate` delegates.
    public weak var delegate: ControlInputSourceDelegate?
    public weak var gameStateDelegate: ControlInputSourceGameStateDelegate?
    
    public let allowsStrafing = true
    
    // Analog thumb stick controls for the left and right half of the screen.
    public let leftThumbStickNode: ThumbStickNode
    public let rightThumbStickNode: ThumbStickNode
    
    // Node representing the touch area for the pause button.
    public let pauseButton: SKSpriteNode
    
    // Sets used to keep track of touches, and their relevant controls.
    public var leftControlTouches: Set<UITouch> = Set<UITouch>()
    public var rightControlTouches: Set<UITouch> = Set<UITouch>()
    
    // The width of the zone in the center of the screen where the touch controls cannot be placed.
    public let centerDividerWidth: CGFloat
    public let configuration: TouchControlConfiguration
    
    public var hideThumbStickNodes: Bool = false {
        didSet {
            leftThumbStickNode.isHidden = hideThumbStickNodes
            rightThumbStickNode.isHidden = hideThumbStickNodes
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    // `TouchControlInputNode` is intended as an overlay for the entire screen, therefore the `frame` is usually the scene's bounds or something equivalent.
    public init(frame: CGRect, configuration: TouchControlConfiguration) {
        
        // An approximate width appropriate for different scene sizes.
        centerDividerWidth = frame.width / 4.5
        
        // Setup the thumbStickNodes.
        let initialVerticalOffset: CGFloat = -configuration.thumbStickNodeSize.height
        let initialHorizontalOffset: CGFloat = frame.width / 2 - configuration.thumbStickNodeSize.width
        
        leftThumbStickNode = ThumbStickNode(size: configuration.thumbStickNodeSize)
        leftThumbStickNode.position = CGPoint(x: -initialHorizontalOffset,
                                              y: initialVerticalOffset)
        
        rightThumbStickNode = ThumbStickNode(size: configuration.thumbStickNodeSize)
        rightThumbStickNode.position = CGPoint(x: initialHorizontalOffset,
                                               y: initialVerticalOffset)
        
        // Setup pause button.
        let buttonSize: CGSize = CGSize(width: frame.height / 4, height: frame.height / 4)
        pauseButton = SKSpriteNode(texture: nil, color: UIColor.clear, size: buttonSize)
        pauseButton.position = CGPoint(x: 0, y: frame.height / 2)
        
        // Store the configuration
        self.configuration = configuration
        
        super.init(texture: nil, color: UIColor.clear, size: frame.size)
        rightThumbStickNode.delegate = self
        leftThumbStickNode.delegate = self
    
        addChilds([leftThumbStickNode, rightThumbStickNode, pauseButton])
        
        // A `TouchControlInputNode` is designed to receive all user interaction and forwards it along to the child nodes.
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - UIResponder
    // -----------------------------------------------------------------
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            
            let touchPoint: CGPoint = touch.location(in: self)
            
            // Ignore touches if the thumb stick controls are hidden, or if the touch is in the center of the screen.
            let touchIsInCenter: Bool = touchPoint.x < centerDividerWidth / 2 && touchPoint.x > -centerDividerWidth / 2
            
            if hideThumbStickNodes || touchIsInCenter {
                continue
            }
            
            if touchPoint.x < 0 {
                leftControlTouches.formUnion([touch])
                leftThumbStickNode.position = pointByCheckingControlOffset(suggestedPoint: touchPoint)
                leftThumbStickNode.touchesBegan([touch], with: event)
            } else {
                rightControlTouches.formUnion([touch])
                rightThumbStickNode.position = pointByCheckingControlOffset(suggestedPoint: touchPoint)
                rightThumbStickNode.touchesBegan([touch], with: event)
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        /*
            If the touch pertains to a `thumbStickNode`, pass the
            touch along to be handled.
            
            Holding onto individual touches allows the user to drag
            a touch that initially started on the `leftThumbStickNode`
            over the the `rightThumbStickNode`s zone or vice versa,
            while ensuring it is handled by the correct thumb stick.
        */
        let movedLeftTouches: Set<UITouch> = touches.intersection(leftControlTouches)
        leftThumbStickNode.touchesMoved(movedLeftTouches, with: event)
        
        let movedRightTouches: Set<UITouch> = touches.intersection(rightControlTouches)
        rightThumbStickNode.touchesMoved(movedRightTouches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches {
            let touchPoint = touch.location(in: self)
            
            // Toggle pause when touching in the pause node.
            if pauseButton === atPoint(touchPoint) {
                gameStateDelegate?.controlInputDidTogglePauseState(self)
                break
            }
        }
        
        let endedLeftTouches: Set<UITouch> = touches.intersection(leftControlTouches)
        leftThumbStickNode.touchesEnded(endedLeftTouches, with: event)
        leftControlTouches.subtract(endedLeftTouches)
        
        let endedRightTouches: Set<UITouch> = touches.intersection(rightControlTouches)
        rightThumbStickNode.touchesEnded(endedRightTouches, with: event)
        rightControlTouches.subtract(endedRightTouches)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)

        leftThumbStickNode.resetTouchPad()
        rightThumbStickNode.resetTouchPad()
        
        // Keep the set's capacity, because roughly the same number of touch events are being received.
        leftControlTouches.removeAll(keepingCapacity: true)
        rightControlTouches.removeAll(keepingCapacity: true)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Convenience Methods
    // -----------------------------------------------------------------
    
    // Calculates a point that keeps the `thumbStickNode` completely on screen.
    func pointByCheckingControlOffset(suggestedPoint: CGPoint) -> CGPoint {
        
        // `leftThumbStickNode` is an arbitrary choice - both are the same size.
        let controlSize: CGSize = leftThumbStickNode.size
        
        guard let sceneSize: CGSize = scene?.size else {
            return .zero
        }
        
        /*
            The origin of `SKNode`'s coordinate system is at the center of the screen.
            Points to the left and below the origin are negative;
            points above and to the right are positive.
            
            Offset by 2/3 times the size of the control to maintain some padding
            around the edge of the view.
        */
        let minX: CGFloat = -sceneSize.width / 2 + controlSize.width / 1.5
        let maxX: CGFloat = sceneSize.width / 2 - controlSize.width / 1.5
        
        let minY: CGFloat = -sceneSize.height / 2 + controlSize.height / 1.5
        let maxY: CGFloat = sceneSize.height / 2 - controlSize.height / 1.5
        
        let boundX: CGFloat = max(min(suggestedPoint.x, maxX), minX)
        let boundY: CGFloat = max(min(suggestedPoint.y, maxY), minY)
        
        return CGPoint(x: boundX, y: boundY)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GenericInputSourceDelegate
    // -----------------------------------------------------------------
    
    public func resetControlState() {
        // Nothing to do here.
    }
}

extension TouchControlInputSource: ThumbStickNodeDelegate {
    
    // -----------------------------------------------------------------
    // MARK: - ThumbStickNodeDelegate
    // -----------------------------------------------------------------
    
    func thumbStickNode(thumbStickNode: ThumbStickNode, didUpdateXValue xValue: Float, yValue: Float) {
        
        let displacement: SIMD2<Float> = SIMD2<Float>(x: xValue, y: yValue)
        
        // Determine which control this update is relevant to by comparing it to the references.
        if thumbStickNode === leftThumbStickNode {
            delegate?.inputSource(self, didUpdateDisplacement: SIMD2<Float>(x: xValue, y: yValue))
        } else {
            
            // Rotate the character only if the `thumbStickNode` is sufficiently displaced.
            if length(displacement) >= configuration.minimumRequiredThumbstickDisplacement {
                delegate?.inputSource(self, didUpdateAngularDisplacement: displacement)
            } else {
                delegate?.inputSource(self, didUpdateAngularDisplacement: SIMD2<Float>())
            }
        }
    }
    
    func thumbStickNode(thumbStickNode: ThumbStickNode, isPressed: Bool) {
        if thumbStickNode === rightThumbStickNode {
            if isPressed {
                delegate?.inputSourceDidBegin(self)
            } else {
                delegate?.inputSourceDidFinish(self)
            }
        }
    }
}

#endif
