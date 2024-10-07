//
//  LevelScene+Editor.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 04/12/2022.
//

#if os(macOS)
import AppKit
#endif

import SpriteKit
import GameplayKit
import Engine

extension LevelScene {
    
    /// Lock onto a scene item
    func sceneItemAtLocation(event: GameEvent) {
        model.selectedNode = Set(self.nodes(at: event.data.location(in: self)).filter({model.furniture.contains($0)})).first
        model.selectedNode?.entity?.component(ofType: BoundaryComponent.self)?.addBoundryBox()
    }
    
    func editorModePhysicsContact(item: GKEntity) {
        
        guard let spriteNode = item.component(ofType: RenderComponent.self)?.spriteNode, spriteNode == model.selectedNode else {
            return
        }
        
        model.selectedNode?.removeAllActions()
    }
}
