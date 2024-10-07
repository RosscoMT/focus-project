//
//  LevelSceneFurnitureStoreState.swift
//
//
//  Created by Ross Viviani on 29/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import GameplayKit
import Engine

/// Level scene state used for adding furniture items into the game level
final class LevelSceneFurnitureStoreState: LevelSceneOverlayBaseState {
    
    typealias LevelConfig = GameplayConfiguration.Level
    
    lazy var model: LevelSceneFurnitureStoreDataModel = LevelSceneFurnitureStoreDataModel(view: self)
    
    // -----------------------------------------------------------------
    // MARK: - Properties
    // -----------------------------------------------------------------
    
    override var overlaySceneFileName: GameResources {
        return .addScene
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - GKState Life Cycle
    // -----------------------------------------------------------------
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        print("Furniture store state")
        
        // Add the available furniture items to the table view
        setupTableItems()
        
        // Flush all set data by the user
        model.items.removeAll()
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        resetTableView()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        nextState(withClass: stateClass)
    }
    
    // -----------------------------------------------------------------
    // MARK: - Method
    // -----------------------------------------------------------------
    
    /// Setups the game store based on the games configurations
    func setupTableItems() {
        
        // Assign initial cost and balance labels
        model.costLabel.text = GameFormatter.currencyFormatter.string(from: .init(floatLiteral: .zero))
        model.balanceLabel.text = GameFormatter.currencyFormatter.string(from: .init(floatLiteral: levelScene.levelConfiguration.startingBalance))
        model.shipButton.defaultSetting(false)
        
        // Cycle through furniture items to create the individual cells
        for index in 0..<model.furniture.count {
            
            let item = model.furniture[index]
            
            let nodeItem: SKSpriteNode = SKNode.loadNode(scene: "AddItemCell",
                                                         node: GameNodes.addFurnitureTableCell)
            
            nodeItem.cell().name.text = item.name.handle()
            nodeItem.cell().price.text = GameFormatter.currencyFormatter.string(from: .init(floatLiteral: item.price))
            nodeItem.cell().quantity.text = "0"
            nodeItem.userData = .init(dictionaryLiteral: ("FurnitureItem", item.name.rawValue))
            nodeItem.position.y -= nodeItem.frame.height * CGFloat(index)
            //nodeItem.shader = shader.
            model.addItemsTableView?.addChild(nodeItem)
        }
    }
    
    func adjustFurnitureItem(button: ButtonNode) {
        
        // Add or subtract furniture items to spawn
        guard let userData: String = button.parent?.userData?["FurnitureItem"] as? String, let key = FurnitureType.init(rawValue: userData) else {
            return
        }
        
        // Add or subtract furniture items to spawn
        model.items.update(operation: button.buttonIdentifier, key: key)
        
        // Update label
        button.parent?.cell().quantity.text = "\(model.items[key]!)"
        
        // Update shipButton based on if the user has selected any items
        model.shipButton.isActive = model.items[key]! > 0 ? true : false
        
        // Calculates the total
        let cost = model.items.calculateOrder(dataSet: levelScene.levelConfiguration.furnitureLibrary)
        model.costLabel.text = GameFormatter.currencyFormatter.string(from: .init(floatLiteral: cost))
    }
    
    // Clean table view when leaving state
    func resetTableView() {
        model.addItemsTableView?.children.forEach({$0.removeFromParent()})
    }
}


fileprivate extension SKNode {
    
    
    /// Retrieve the furniture item cell data
    /// - Returns: Data model of the cells relevant child nodes
    func cell() -> LevelSceneFurnitureStoreDataModel.CellModel {
   
        guard let name: SKLabelNode = self.childNode(name: GameNodes.addFurnitureTableCellName) as? SKLabelNode, let price: SKLabelNode = self.childNode(name: GameNodes.addFurnitureTableCellPrice) as? SKLabelNode, let quantity: SKLabelNode = self.childNode(name: GameNodes.addFurnitureTableCellQuantity) as? SKLabelNode else {
            fatalError("Incorrect cell")
        }
        
        return .init(name: name, price: price, quantity: quantity)
    }
}

fileprivate extension Dictionary where Self == Dictionary<FurnitureType, Int> {
    
    /// Updates the dictionary by ButtonIdentifier and FurnitureType
    /// - Parameters:
    ///   - operation: The ButtonIdentifier called
    ///   - key: The funiture type to update
    mutating func update(operation: ButtonIdentifier?, key: FurnitureType) {
        
        // If value is zero, then initialise to prevent crashing
        if self[key] == nil {
            self[key] = 0
        }
        
        // Per button type, either increase of decrease the quantity
        switch operation {
        case .plus:
            self[key]! += 1
        case .minus:
            if self[key]! > 0 {
                self[key]! -= 1
            }
        default:
            return
        }
    }
}
