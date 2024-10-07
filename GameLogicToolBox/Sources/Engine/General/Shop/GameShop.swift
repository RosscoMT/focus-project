//
//  GameShop.swift
//  
//
//  Created by Ross Viviani on 08/03/2024.
//

import Foundation

public extension Dictionary where Key: RawRepresentable, Key.RawValue == String, Key: Hashable, Value == Int {
    
    
    /// Calculates a total for an order based what items the user has selected against the known price list
    /// - Parameter dataSet: The set of data which contains the items and their pricing
    /// - Returns: The total
    func calculateOrder<T: RawRepresentable<String>>(dataSet: Set<ShoppingItem<T>>) -> Double {
        
        var cost: Double = 0
        
        self.forEach { key, value in
            
            guard let itemData = dataSet.first(where: {$0.name.rawValue == key.rawValue }) else {
                return
            }
            
            cost += itemData.price * Double(value)
        }
        
        return cost
    }
}


