//
//  TestFormatters.swift
//
//
//  Created by Ross Viviani on 09/03/2024.
//

import XCTest

@testable import Engine

final class TestFormatters: XCTestCase {
    
    func testCurrencyFormatter() {
        
        // Set the locale to a specific value
        let locale = Locale(identifier: "en_US")
        GameFormatter.updateFormattersLocal(local: locale)
        
        // Use the currency formatter to format a number
        let formattedAmount = GameFormatter.currencyFormatter.string(from: 100.00)
        
        // Assert that the formatted amount matches the expected result
        XCTAssertEqual(formattedAmount, "$100.00", "Currency formatter should format correctly")
    }
}

