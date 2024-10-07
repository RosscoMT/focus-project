//
//  InteractionPadComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 21/04/2023.
//

import GameplayKit
import Engine

/// Pad component allows for detecting of other sprites which have moved onto it
class InteractionPadComponent: GKComponent {
    
    struct Pad: Equatable, Hashable {
        let direction: Direction
        let node: PadSprite
    }
    
    @GKInspectable var position: String = ""
    @GKInspectable var sides: Int = 1
    
    // Store unavailable pads
    static public var unavailablePads: Set<SKNode> = []
    
    var padPosition: Direction?
    var interactionSides: Int?
    var generatedPads: [Pad] = []
    var scene: SKScene?
    var id: UUID = .init()
    
    var frame: CGRect {
        return componentNode.frame
    }

    override func didAddToEntity() {
        
        // Decode position from either scene of manual implementation
        padPosition = Direction.direction(from: position)
     
        // Transfer sides
        interactionSides = interactionSides == nil ? sides : interactionSides
        
        // Check how many specified side
        switch interactionSides ?? 0 {
            
            // If no sides simply return
            case 0:
                return
            
            // Generate single pad
            case 1:
                let node = generateInteractionPad(direction: padPosition!)
                generatedPads.append(.init(direction: padPosition!, node: node))
            
            case 2...3:
          
            // Generate pad for two sides
            Direction.random(range: interactionSides!).forEach({ side in
                let node = generateInteractionPad(direction: side)
                generatedPads.append(.init(direction: padPosition!, node: node))
            })
            
            // Generate all positions
            default:
                Direction.allCases.forEach({ side in
                    let node = generateInteractionPad(direction: side)
                    generatedPads.append(.init(direction: side, node: node))
                })
        }
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

extension InteractionPadComponent {
    
    convenience init(_ position: Direction) {
        self.init()
        self.padPosition = position
    }
    
   func zonePosition(position: Direction, node: SKSpriteNode) {
        
        // Position the pad based on the position of the render, while using different anchor points per direction
        switch position {
        case .up:
            node.position = .init(x: frame.minX, y: frame.maxY)
            node.anchorPoint = .init(x: 0, y: 0)
        case .down:
            node.position = .init(x: frame.minX, y: frame.minY)
            node.anchorPoint = .init(x: 0, y: 1)
        case .left:
            node.position = .init(x: frame.minX, y: frame.minY)
            node.anchorPoint = .init(x: 1, y: 0)
        case .right:
            node.position = .init(x: frame.maxX, y: frame.minY)
            node.anchorPoint = .init(x: 0, y: 0)
        }
    }
    
    private func generateInteractionPad(direction: Direction) -> PadSprite {

        // Setup pad with transparency
        let padSprite = PadSprite(colour: .lightGray,
                                  size: .init(width: componentNode.frame.width, 
                                              height: componentNode.frame.height),
                                  parentNode: self.componentNode)
        padSprite.alpha = 0.5
        padSprite.zPosition = WorldLayerPositioning.background.rawValue
        padSprite.name = "Zone - \(id)"
        zonePosition(position: direction, node: padSprite)
        
        // Control the display of the interaction pads
        SceneManager.executeDebugRequests {
            padSprite.isHidden = !GameplayConfiguration.Debug.displayInteractionPad
        }
        
        // Supports adding from SKScene and manually
        if let scene = componentNode.scene {
            scene.addChild(padSprite)
        } else {
            self.scene?.addChild(padSprite)
        }

        return padSprite
    }
}

extension SKNode {
 
    // Convenient extraction of the interaction pad component
    func interactionPadComponent() -> InteractionPadComponent? {
        
        guard let component = entity?.component(ofType: InteractionPadComponent.self) else {
            return nil
        }
         
        return component
    }
}
