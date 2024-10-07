//
//  CoffeeHouseTests.swift
//  CoffeeHouseTests
//
//  Created by Ross Viviani on 30/03/2023.
//

import XCTest
@testable import CoffeeHouse

final class MenuInteractionTests: XCTestCase {
    
    var sut: BaseScene?
    
    override func setUp() {
        
        let buttonOne = ButtonNode()
        buttonOne.name = "StartButton"
        buttonOne.isSelected = true
        
        let buttonTwo = ButtonNode()
        buttonTwo.name = "OptionsButton"
        
        let buttonThree = ButtonNode()
        buttonThree.name = "LoadButton"
        
        sut = BaseScene()
        sut?.buttons = [buttonOne, buttonTwo, buttonThree]
    }

    // That you can select other items in the menu using a directional down input
    func testMenuCyclingDown() {
        
        sut?.highlightButton(direction: .down)
        
        XCTAssertTrue((sut?.buttons[1].isSelected)!)
        XCTAssertFalse((sut?.buttons[0].isSelected)!)
        XCTAssertFalse((sut?.buttons[2].isSelected)!)
    }
    
    // That you can select other items in the menu using a directional up input
    func testMenuCyclingUp() {
        
        sut?.highlightButton(direction: .up)
        
        XCTAssertTrue((sut?.buttons[2].isSelected)!)
        XCTAssertFalse((sut?.buttons[0].isSelected)!)
        XCTAssertFalse((sut?.buttons[1].isSelected)!)
    }
    
    // That you can select other items in the menu using a directional left input
    func testMenuCyclingLeftKey() {
        
        sut?.highlightButton(direction: .left)
        
        XCTAssertTrue((sut?.buttons[0].isSelected)!)
        XCTAssertFalse((sut?.buttons[1].isSelected)!)
        XCTAssertFalse((sut?.buttons[2].isSelected)!)
    }
    
    // That you can select other items in the menu using a directional right input
    func testMenuCyclingRightKey() {
        
        sut?.highlightButton(direction: .right)
        
        XCTAssertTrue((sut?.buttons[0].isSelected)!)
        XCTAssertFalse((sut?.buttons[1].isSelected)!)
        XCTAssertFalse((sut?.buttons[2].isSelected)!)
    }
}
