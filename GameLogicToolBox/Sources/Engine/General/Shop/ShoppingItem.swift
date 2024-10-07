//
//  ShoppingItem.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 07/03/2024.
//

import Foundation

/// Reusable generic shop item ie table, carpet, till, chair...
/// Requires enum of string value for name
public struct ShoppingItem<T: RawRepresentable<String> & Hashable & Decodable>: Hashable, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case price
    }
    
    public let name: T
    public let price: Double
    
    public init(name: T, price: Double) {
        self.name = name
        self.price = price
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(T.self, forKey: .name)
        self.price = try container.decode(Double.self, forKey: .price)
    }
}

