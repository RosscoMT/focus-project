//
//  GKState+Extension.swift
//  
//
//  Created by Ross Viviani on 26/11/2022.
//

import GameplayKit

public extension GKState {
    
   enum State: String {
        case initial
        case downloadingResource
        case downloadFailed
        case resourceAvailable
        case preparingResource
        case resourceReady
    }
    
    func logCurrentState(state: State, scene: String) {
        print("----Entering----\nState: \(state.rawValue) State\nScene: \(scene)")
    }
}
