//
//  Array+Extension.swift
//
//
//  Created by Ross Viviani on 16/04/2024.
//

import Foundation

public extension Array where Element == Date {
    
    /// Appends a new date to the current array
    mutating func appendNewDate() {
        self.append(.init())
    }
}
