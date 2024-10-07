//
//  FurnitureDataModel.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 25/04/2023.
//

import Foundation
import Engine

/// Data model for decoding the furniture property list
struct FurnitureDataModel: Decodable {
    let name: FurnitureType
    let size: CGSize
    let imageName: String
    let interactionSides: Int?
}

// The available furniture types
enum FurnitureType: String, CaseIterable, Decodable, Handle {
    
    case table
    case till
    case collectionArea
    case coffeeMachine
    case obstacle
    case chair
    case counter
    case light
    case window
    case door
    case plant
    case carpet
    case standingCabinet
    case floorCabinet
    case none
    
    func handle() -> String {
        return self.rawValue.captializeString()
    }
    
    static func furnitureType(name: String) -> FurnitureType {
        
        guard let item = FurnitureType.allCases.first(where: {$0.rawValue.captializeString() == name}) else {
            assertionFailure("Incorrect scene level item name")
            return .none
        }
        
        return item
    }
    
    static func assetName(name: String?) -> FurnitureType {
        
        if let assetName = name, let asset = FurnitureType.allCases.first(where: {$0.rawValue.lowercased() == assetName.lowercased()}) {
            return asset
        } else {
            fatalError("asset is not listed or incorrectly named")
        }
    }
}
