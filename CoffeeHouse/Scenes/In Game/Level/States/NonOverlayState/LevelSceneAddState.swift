//
//  LevelSceneEditorState.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 23/11/2022.
//

import GameplayKit
import Engine

/// State dedicated to allowing newly added items to be added to the game level
class LevelSceneAddState: GKState {
    

    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    unowned let levelScene: LevelScene
    
    var items: Dictionary = Dictionary<FurnitureType, Int>()
    
    
    // -----------------------------------------------------------------
    // MARK: - Initializers
    // -----------------------------------------------------------------
    
    init(levelScene: LevelScene) {
        self.levelScene = levelScene
    }
    
    func setupState(items: Dictionary<FurnitureType, Int>) {
        
        // Assigns the selected nodes
        self.items = items

        // Begin adding nodes to scene
        addFunitureItem()
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Methods
    // -----------------------------------------------------------------
    
    /// Add the selected furniture items to the scene
    func addFunitureItem() {
        
        // Fetch the first
        guard let item = items.first else {
            
            // Exit the add furniture state once
            levelScene.stateMachine.enter(LevelScenePlayingState.self)
            
            return
        }
        
        // Create entity and configure it
        let entity = Furniture(furnitureType: item.key, scene: self.levelScene)
        entity.componentNode.position = levelScene.camera?.position ?? .zero
        entity.boundryComponent.addBoundryBox()
        
        // Add the new furniture item to the scene
        levelScene.addEntity(entity: entity, layer: self.levelScene.model.furnitureNode, zLayer: .furniture)
        
        // Hold a reference to the new furniture item, till the player has positioned it
        levelScene.model.selectedNode = entity.componentNode
        
        // Check that the newly placed furniture position is valid
        validateFurnituresPosition(node: entity.componentNode)
        
        // Update the items
        updateItems(key: item.key)
    }
    
    /// Validates the position of the furniture which has just been placed in the scene
    func validateFurnituresPosition(node: SKNode) {
        
        // Quick access to the components of the furniture item entity
        let components = Furniture.extractComponent(node: node)
        
        // Generate the boundary box
        let bufferNode: SKNode = BoundaryComponent.generateNodeWithBoundaryBox(node: node,
                                                                              position: node.position)
        
        // Construct the array of furniture items to consider
        let furnitureNodes = levelScene.excludeFurniture()
        
        // Check if the furniture node with its boundary box are clipping any other furniture items
        if furnitureNodes.intersectsNode(node: bufferNode) {
            components.boundryComponent.recolourBoundryBox(true)
        }
    }
    
    // Releases the funriture item and removes any player visuals
    func confirmPlacement() {
        
        guard let boundaryBox = levelScene.model.selectedNode?.component(BoundaryComponent.self) else {
            fatalError("Boundary box failed to be found")
        }
        
        boundaryBox.removeBoundryBox()
        
        // Remove the handle from the furniture item
        levelScene.model.selectedNode = nil
        
        // Add any other new furniture 
        addFunitureItem()
    }
    
    // Updates the list of items to add into the level
    func updateItems(key: FurnitureType) {
        
        let value: Int = items[key] ?? .zero
        
        let updatedValue = value - 1
        
        // If the new value is equal of less than zero, remove from the items
        if updatedValue <= 0 {
            items.removeValue(forKey: key)
        } else {
            items[key] = updatedValue
        }
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        print("Adding furniture state")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }
}
