//
//  ThumbStickNode.swift
//
//
//  Created by Ross Viviani on 12/10/2022.
//

import SpriteKit

#if os(iOS) || os(tvOS)

// Relay control events though `ThumbStickNodeDelegate`.
protocol ThumbStickNodeDelegate: AnyObject {
    
    // Called when `touchPad` is moved. Values are normalized between [-1.0, 1.0].
    func thumbStickNode(thumbStickNode: ThumbStickNode, didUpdateXValue xValue: Float, yValue: Float)
    
    // Called to indicate when the `touchPad` is initially pressed, and when it is released.
    func thumbStickNode(thumbStickNode: ThumbStickNode, isPressed: Bool)
}

/// An iOS-specific `SKSpriteNode` subclass used to provide the on-screen thumbsticks that enable player control.
/// 
/// Touch representation of a classic analog stick.
public class ThumbStickNode: SKSpriteNode {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    // The actual thumb pad that moves with touch.
    var touchPad: SKSpriteNode
    
    weak var delegate: ThumbStickNodeDelegate?
    
    // The center point of this ThumbStickNode
    let center: CGPoint
    
    // The distance that touchPad can move from the touchPadAnchorPoint
    let trackingDistance: CGFloat
    
    // Styling settings for the thumbstick's nodes.
    let normalAlpha: CGFloat = 0.3
    let selectedAlpha: CGFloat = 0.5
    
    
    public override var alpha: CGFloat {
        didSet {
            touchPad.alpha = alpha
        }
    }

    
    // -----------------------------------------------------------------
    // MARK: - Initialization
    // -----------------------------------------------------------------
    
    init(size: CGSize) {
        trackingDistance = size.width / 2
        
        let touchPadLength: Double = size.width / 2.2
        center = CGPoint(x: size.width / 2 - touchPadLength, y: size.height / 2 - touchPadLength)
        
        let touchPadSize: CGSize = CGSize(width: touchPadLength, height: touchPadLength)
        let touchPadTexture: SKTexture = SKTexture(imageNamed: "ControlPad")
        
        // `touchPad` is the inner touch pad that follows the user's thumb.
        touchPad = SKSpriteNode(texture: touchPadTexture, color: UIColor.clear, size: touchPadSize)
        
        super.init(texture: touchPadTexture, color: UIColor.clear, size: size)

        alpha = normalAlpha
        
        addChild(touchPad)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - UIResponder
    // -----------------------------------------------------------------
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Highlight that the control is being used by adjusting the alpha.
        alpha = selectedAlpha
        
        // Inform the delegate that the control is being pressed.
        delegate?.thumbStickNode(thumbStickNode: self, isPressed: true)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // For each touch, calculate the movement of the touchPad.
        for touch in touches {
            let touchLocation: CGPoint = touch.location(in: self)
            
            var dx: Double = touchLocation.x - center.x
            var dy: Double = touchLocation.y - center.y
            
            // Calculate the distance from the `touchPadAnchorPoint` to the current location.
            let distance: Double = hypot(dx, dy)
            
            // If the distance is greater than our allowed `trackingDistance`, create a unit vector and multiply by max displacement (`trackingDistance`).
            if distance > trackingDistance {
                dx = (dx / distance) * trackingDistance
                dy = (dy / distance) * trackingDistance
            }
            
            // Position the touchPad to match the touch's movement.
            touchPad.position = CGPoint(x: center.x + dx,
                                        y: center.y + dy)
            
            // Normalize the displacements between [-1.0, 1.0].
            let normalizedDx: Float = Float(dx / trackingDistance)
            let normalizedDy: Float = Float(dy / trackingDistance)
            delegate?.thumbStickNode(thumbStickNode: self, didUpdateXValue: normalizedDx, yValue: normalizedDy)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // If the touches set is empty, return immediately.
        guard !touches.isEmpty else {
            return
        }
        
        resetTouchPad()
   }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        resetTouchPad()
    }
    
    // When touches end, reset the `touchPad` to the center of the control.
    func resetTouchPad() {
        alpha = normalAlpha
        
        let restoreToCenter: SKAction = SKAction.move(to: CGPoint.zero, duration: 0.2)
        touchPad.run(restoreToCenter)
        
        delegate?.thumbStickNode(thumbStickNode: self, isPressed: false)
        delegate?.thumbStickNode(thumbStickNode: self, didUpdateXValue: 0, yValue: 0)
    }
}

#endif
