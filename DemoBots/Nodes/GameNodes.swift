//
//  GameNodes.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 07/11/2023.
//

import SpriteKit
import Engine

enum GameNodes: String, Handle {
    
    // Progress scene
    case backgroundNode
    case progressLabel
    case progressBar
    case progressBarBackground
    
    // Level scene
    case world
    case playerSpawnLocation = "PlayerSpawnLocation"
    case customerSpawnLocation = "CustomerSpawnLocation"
    case board
    case characters
    case entrance
    case furniture
    case obstacles
    case obstacle
    case placed
    
    // Menu bar
    case customerNumber
    case menuBar
    case toggleInteraction
    case help
    case appMenuButton
    case furnitureNumber
    case addFurniture
    
    // Add Furniture Items
    case addFurnitureTable
    case addFurnitureTableCell
    case addFurnitureTableCellName
    case addFurnitureTableCellQuantity
    case addFurnitureTableCellPrice
    case addFurnitureCostPrice
    case addFurnitureBalance
    case addFurnitureShipButton = "AddFurnitureShipButton"
    case addFurnitureCancelButton = "AddFurnitureCancelButton"
    
    // Scene overlay
    case overlay = "Overlay"
    
    // References the menus used in the game
    static let menus: [GameNodes] = [.appMenuButton, .help, .toggleInteraction, .addFurniture]
    
    // Returns the formatted names of the listed nodes
    func handle() -> String {
    
        switch self {
        case .customerNumber, .menuBar, .toggleInteraction, .appMenuButton, .help, .furnitureNumber, .obstacle, .addFurniture, .addFurnitureTable, .addFurnitureTableCell, .addFurnitureCostPrice, .addFurnitureBalance:
            return self.rawValue.captializeString()
        default:
            return self.rawValue
        }
    }
 
    // Returns the a constructed path to a scenes nodes ie world/furniture/Till
    static func pathTo(node: FurnitureType) -> String {

        switch node {
        case .door:
            return [GameNodes.world.rawValue, GameNodes.entrance.handle(), node.rawValue.captializeString()].joined(separator: "/")
        default:
            return [GameNodes.world.rawValue, GameNodes.furniture.handle(), node.rawValue.captializeString()].joined(separator: "/")
        }
    }
}
