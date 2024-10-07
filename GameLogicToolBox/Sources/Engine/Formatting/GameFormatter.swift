//
//  GameFormatter.swift
//
//
//  Created by Ross Viviani on 02/03/2024.
//

import Foundation

/// Formatters to used across the game
public struct GameFormatter {
    
    static let formatter = NumberFormatter()
    
    /// Formats for currency
    public static let currencyFormatter = {
        formatter.numberStyle = .currency
        return formatter
    }()
    
    // Update the local used by the formatter
    public static func updateFormattersLocal(local: Locale) {
        GameFormatter.formatter.locale = local
    }
}
