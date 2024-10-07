//
//  Date+Extension.swift
//  
//
//  Created by Ross Viviani on 11/04/2024.
//

import Foundation

public extension Date {
    
    func secondDifference() -> Double {
        return Date().timeIntervalSince(self)
    }
}
