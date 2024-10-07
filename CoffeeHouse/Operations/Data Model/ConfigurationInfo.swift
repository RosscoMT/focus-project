//
//  ConfigurationInfo.swift
//  DemoBots
//
//  Created by Ross Viviani on 07/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation
import Engine

struct ConfigurationInfo: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case initialPlayerBotOrientation
        case navigationGraphPaths
        case startingBalance
        case furnitureLibrary
    }
    
    let initialPlayerBotOrientation: CompassDirection
    let navigationGraphPaths: [NavigationGraphPaths]
    let startingBalance: Double
    let furnitureLibrary: Set<ShoppingItem<FurnitureType>>
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.initialPlayerBotOrientation = CompassDirection(string: try values.decode(String.self, forKey: .initialPlayerBotOrientation))
        self.navigationGraphPaths = try values.decode([NavigationGraphPaths].self, forKey: .navigationGraphPaths)
        self.startingBalance = try values.decode(Double.self, forKey: .startingBalance)
        self.furnitureLibrary = try values.decode(Set<ShoppingItem<FurnitureType>>.self, forKey: .furnitureLibrary)
    }
}
