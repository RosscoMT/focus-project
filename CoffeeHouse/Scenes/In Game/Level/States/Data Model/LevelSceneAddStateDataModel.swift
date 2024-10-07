//
//  LevelSceneAddStateDataModel.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 09/03/2024.
//

import SpriteKit

struct LevelSceneFurnitureStoreDataModel {
    
    struct CellModel {
        let name: SKLabelNode
        let price: SKLabelNode
        let quantity: SKLabelNode
    }
    
    let view: LevelSceneOverlayBaseState
    
    var items: Dictionary = Dictionary<FurnitureType, Int>()
    
    lazy var shipButton: ButtonNode = {
        return view.overlay.contentNode.childNode(withName: GameNodes.addFurnitureShipButton.handle()) as! ButtonNode
    }()
    
    lazy var balanceLabel: SKLabelNode = {
        return view.overlay.contentNode.childNode(withName: GameNodes.addFurnitureBalance.handle()) as! SKLabelNode
    }()
    
    lazy var costLabel: SKLabelNode = {
        return view.overlay.contentNode.childNode(withName: GameNodes.addFurnitureCostPrice.handle()) as! SKLabelNode
    }()
    
    lazy var addItemsTableView = {
        return view.overlay.contentNode.childNode(withName: GameNodes.addFurnitureTable.handle())
    }()
    
    lazy var furniture = Array(view.levelScene.levelConfiguration.furnitureLibrary) 
}
