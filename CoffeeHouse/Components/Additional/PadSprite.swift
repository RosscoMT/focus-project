//
//  PadSprite.swift
//  CoffeeHouse(iOS)
//
//  Created by Ross Viviani on 11/12/2023.
//

import SpriteKit

// Custom sprite used for allowing quick access to the parent node
class PadSprite: SKSpriteNode {
    var parentNode: SKNode?
    
    convenience init(colour: SKColor, size: CGSize, parentNode: SKNode) {
        self.init(texture: nil, color: colour, size: size)
        self.parentNode = parentNode
    }
}
