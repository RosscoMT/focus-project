//
//  DebugComponent.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 28/05/2023.
//

import GameplayKit

public class DebugComponent: GKComponent {
    
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    let attributedSettings: [NSAttributedString.Key : Any] = {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
    #if os(macOS)
        return [.foregroundColor : NSColor.black, .font : NSFont.systemFont(ofSize: 16, weight: .medium), .paragraphStyle : paragraph]
    #elseif os(iOS)
        return [.foregroundColor : UIColor.black, .font : UIFont.systemFont(ofSize: 16, weight: .medium), .paragraphStyle : paragraph]
    #endif
    }()
    
    /// Reference to the current debug box information
    public var debugText: String = "" {
        didSet {
            generate(text: debugText)
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    /// Generate a new debug label based on the new text - (WARNING - WILL INCREASE DRAW COUNT DURING USUAGE DUE TO SKLABEL)
    private func generate(text: String) {
        
        // Remove all nodes to redraw the whole debug view again
        componentNode.childNode(withName: "debugBox")?.removeFromParent()
        componentNode.childNode(withName: "container")?.removeFromParent()
        
        // Setup the initial debug box
        let debugBox: SKLabelNode = SKLabelNode(attributedText: .init(string: text, attributes: attributedSettings))
        debugBox.numberOfLines = 0
        debugBox.lineBreakMode = .byWordWrapping
        debugBox.preferredMaxLayoutWidth = componentNode.frame.width - 10
        debugBox.zPosition = componentNode.zPosition
        debugBox.position = .init(x: 0, y: -componentNode.frame.height)
        debugBox.blendMode = .replace
        debugBox.name = "debugBox"
        
        // Setup container for the background
        let container = SKSpriteNode(color: .white,
                                     size: .init(width: componentNode.frame.width, height: debugBox.frame.height))
        
        container.zPosition = componentNode.zPosition
        container.anchorPoint = .init(x: 0.5, y: 0)
        container.position = .init(x: 0, y: -componentNode.frame.height)
        container.name = "container"
        
        // Add the nodes as single items to render, to avoid draw count rapid build up
        componentNode.addChild(container)
        componentNode.addChild(debugBox)
    }
}
    
