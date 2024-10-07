//
//  FurnitureSprite.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 19/06/2023.
//

import GameplayKit
import Engine

struct FurnitureData {
    let node: SKSpriteNode
    let sides: Int?
}

/// Stand alone furniture sprite used in a sks scene
class FurnitureSprite: SKSpriteNode, ResourceLoadableType {
    
    // Stored resource from loading
    static var furnitureModel: [FurnitureDataModel]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.zPosition = WorldLayerPositioning.furniture.rawValue
    }
    
    static func sprite(type: FurnitureType) throws -> FurnitureData? {
        
        // Filter furniture models
        guard let item: FurnitureDataModel = furnitureModel?.first(where: {$0.name == type}) else {
            throw GameErrors.spriteMissing
        }
        
        // Generate sprite
        let spriteNode = SKSpriteNode(imageNamed: item.imageName)
        spriteNode.size = item.size
        spriteNode.name = item.name.rawValue
        
        return .init(node: spriteNode, sides: item.interactionSides)
    }
    
    
    // -----------------------------------------------------------------
    // MARK: - Resource Management Methods
    // -----------------------------------------------------------------
    
    static func loadResources() async {
        
        do {
            
            // Access the resource url
            guard let url: URL = Resources.furnitureTypes.resourcesURL() else {
                assertionFailure("Failed to load property list")
                return
            }
            
            // Decode the plist data from the URL
            FurnitureSprite.furnitureModel = try Data.decodePlistData(url: url)
        } catch {
            assertionFailure("Failed to load resources")
        }
    }
    
    static func purgeResources() {
        FurnitureSprite.furnitureModel = nil
    }
    
    static var resourcesNeedLoading: Bool {
        return FurnitureSprite.furnitureModel == nil
    }
}
