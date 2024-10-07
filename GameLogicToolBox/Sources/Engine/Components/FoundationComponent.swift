//
//  FoundationComponent.swift
//  
//
//  Created by Ross Viviani on 25/11/2023.
//

import GameplayKit

open class FoundationComponent<T: RawRepresentable<String> & Hashable & Equatable>: GKComponent {
    
    // The `RenderComponent` for this component's entity.
    public lazy var renderComponent: RenderComponent = {
        
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
            fatalError("A MovementComponent's entity must have a RenderComponent")
        }
        
        return renderComponent
    }()
    
    // The `AnimationComponent` for this component's entity.
    public lazy var animationComponent: AnimationComponent = {
        
        guard let animationComponent = entity?.component(ofType: AnimationComponent<T>.self) else {
            fatalError("A MovementComponent's entity must have an AnimationComponent")
        }
        
        return animationComponent
    }()
    
    
}
