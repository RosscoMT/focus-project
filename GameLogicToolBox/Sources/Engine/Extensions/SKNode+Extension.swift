//
//  SKNode+Extension.swift
//  
//
//  Created by Ross Viviani on 17/10/2022.
//

import SpriteKit
import GameplayKit

public extension SKNode {
    
    /// Fetches SKNodes from SKScenes, preventing the fatal crash
    /// - Parameters:
    ///   - scene: The scene where the node is located
    ///   - node: The name of the node to load
    /// - Returns: The node successfully copied from the scene
    class func loadNode<T: SKNode, O: RawRepresentable & Handle>(scene: String, node: O) -> T {
        guard let sceneFile: SKScene = SKScene(fileNamed: scene), let nodeItem: T = sceneFile.childNode(withName: node.handle()) as? T else {
            fatalError()
        }
        
        return nodeItem.copy() as! T
    }
    
    /// Use this method for game resources which are referenced only by a string
    class func loadNode<T: SKNode>(scene: String, node: String) -> T {
        guard let sceneFile: SKScene = SKScene(fileNamed: scene) else {
            fatalError()
        }
       
        return sceneFile.childNode(withName: "//" + node)?.copy() as! T
    }
    
    func addChilds(_ value: [SKNode]) {
        
        for node in value {
            addChild(node)
        }
    }
    
    
    // Checks if node has hit its destination
    func contactsThreshold(destination: SKNode, size: CGFloat) -> Bool {
        return destination.frame.intersects(self.frame.insetBy(dx: size, dy: size))
    }
    
    // Custom method for returning a node with or without the base
    func childNode<T: RawRepresentable<String>>(name: T, path: [String] = [], baseExtension: String = "") -> SKNode? {
        
        // Path components for the loating node
        let base: String = baseExtension.isEmpty ? "" : baseExtension + "/"
        let path: String = path.isEmpty ? "" : path.map({$0 + "/"}).reduce("", +)
        
        return childNode(withName: [base, path, name.rawValue].reduce("", +))
    }
    
    // Return the centre point of a sprite
    func centrePoint() -> CGPoint {
        return .init(x: self.frame.midX, y: self.frame.midY)
    }
    
    // Check sprite for animation key
    func animationActive(animationKey: String) -> Bool {
        return self.action(forKey: animationKey) != nil
    }
    
    // Check if sprite is attached to a scene
    func attachedToScene() -> Bool {
        return self.scene != nil
    }
    
    /// Returns the SKNodes frame origin but rounded
    func frameWithRoundedOrigin() -> CGRect {
        return .init(x: round(self.frame.origin.x), y: round(self.frame.origin.y), width: self.frame.width, height: self.frame.height)
    }
    
    /// Add convenience method for quick component retrieval
    func component<T: GKComponent>(_ classType: T.Type) -> T where T : GKComponent {
        
        guard let componentObject = entity?.component(ofType: classType) else {
            fatalError("Node does not have this component")
        }
        
        return componentObject
    }
    
//    /// Increase or decrease magnification by gesture
//    /// - Parameters:
//    ///   - gesture: Incoming gesture data
//    ///   - config: Game configurations relating to the zoomRate, minimumZoom and maximumZoom
//    func magnifyScene(_ gesture: NSMagnificationGestureRecognizer, config: [String : CGFloat]) {
//        
//        guard let zoomRate = config["zoomRate"],
//              let minimumZoom = config["minimumZoom"],
//              let maximumZoom = config["maximumZoom"] else {
//            return
//        }
//        
//        // Get the scaling factor
//        let magnification: CGFloat = gesture.magnification / zoomRate
//        
//        // Prevent zooming beyond the limits
//        guard self.xScale + magnification >= minimumZoom,
//                self.xScale + magnification <= maximumZoom else {
//            return
//        }
//        
//        // Calculate the current visible center of the scene based on the backgroundNode position
//        let viewCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
//        
//        // Adjust for the movement when zooming (scaling centered around the view center)
//        let oldPosition = self.position
//        let newScale = self.xScale + magnification
//        
//        // Apply the new scale
//        self.setScale(newScale)
//        
//        // Adjust the position based on the current visible center (to avoid the left-side scaling bug)
//        let newPosition = CGPoint(x: oldPosition.x * newScale / self.xScale,
//                                  y: oldPosition.y * newScale / self.yScale)
//    }
}

// Factory methods
public extension SKNode {
    
    // Create a node
    static func factoryNode(rect: CGRect, colour: SKColor = .clear) -> SKSpriteNode {
        
        let node: SKSpriteNode = .init(color: colour, size: rect.size)
        node.position = rect.origin
  
        return node
    }
}


extension Collection where Element: SKNode {
    
    
    /// SKNode collection contains
    /// - Parameter node: Any RawRepresentable enum type which conforms to Handle protocol
    /// - Returns: Returns if SKNode is contained in collection
    public func contains<T: RawRepresentable<String> & Handle>(_ node: T) -> Bool {
        return self.contains(where: { $0.name == node.handle() })
    }
    
    /// SKNode collection first
    /// - Parameter node: Any RawRepresentable enum type which conforms to Handle protocol
    /// - Returns: Returns first SKNode if found
    public func first<T: RawRepresentable<String> & Handle>(_ node: T) -> Element? {
        return self.first(where: { $0.name == node.handle() })
    }
    
    /// Check if node is overlapping any in the array
    /// - Parameter node: The node to heck
    /// - Returns: The result
    public func intersectsNode(node: SKNode) -> Bool {
        return self.contains(where: { node.intersects($0)})
    }
    
    /// Quick array of names from SKNodes in the array
    /// - Returns: An array of strings
    public func nodeNames() -> [String] {
        return self.compactMap({$0.name})
    }
    
    /// Checks if collection of SKNodes contains a menu item
    /// - Parameter node: Game Enum which contains
    /// - Returns: Bool true if there was any menu items found in nodes array
    public func contains<T: RawRepresentable & Handle>(menus: [T]) -> Bool {
        
        // Use Sets to allow subtraction
        let nodes: Set<String> = Set<String>(self.nodeNames())
        
        // Subtract the menu nodes from selected nodes, if present
        let results: Set<String> = nodes.subtracting(Set<String>(menus.handleRawValues()))
        
        // Use results and selectedNodes to discover if any menu items were in the selected nodes
        return results.symmetricDifference(Set<String>(self.nodeNames())).isEmpty == false
    }
    
    /// Checks if collection of SKNodes contains a menu item and returns it
    /// - Parameter node: Game Enum which contains
    /// - Returns: The selected menu item and node, if found
    public func selectedMenu<T: RawRepresentable<String> & Handle>(menus: [T]) -> (menu: T, node: SKNode)? {
        
        // Use Sets to allow subtraction
        let nodes: Set<String> = Set<String>(self.nodeNames())
        
        // Subtract the menu nodes from selected nodes, if present
        let results: Set<String> = nodes.subtracting(Set<String>(menus.handleRawValues()))
        
        // Use results and selectedNodes to discover if any menu items were in the selected nodes
        if let item: String = results.symmetricDifference(Set<String>(self.nodeNames())).first, let menuItem = T.init(rawValue: item.reverseFormating()), let node = self.first(where: {$0.name == item})  {
            return (menuItem, node)
        } else {
            return nil
        }
    }
}

public extension String {
    
    /// Reverses the formatting of node names
    func reverseFormating() -> String {
        
        guard self.isEmpty == false else {
            return self
        }
    
        return self.first!.lowercased() + "\(self.dropFirst())"
    }
}
