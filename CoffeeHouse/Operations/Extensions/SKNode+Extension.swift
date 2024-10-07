//
//  SKNode+Extension.swift
//  DemoBots
//
//  Created by Ross Viviani on 19/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import SpriteKit
import Engine

extension SKNode {
    
    convenience init?(asset: GameResources) {
        self.init(fileNamed: asset.rawValue)
    }
    
    func buttonNode(name: ButtonIdentifier) -> SKSpriteNode {
        return childNode(withName: name.rawValue) as! SKSpriteNode
    }
}
