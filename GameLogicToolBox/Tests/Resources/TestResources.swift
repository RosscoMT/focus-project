//
//  TestResources.swift
//  
//
//  Created by Ross Viviani on 14/07/2023.
//

import GameplayKit
import Engine

class SampleComponentOne: GKComponent {}
class SampleComponentTwo: GKComponent {}
class SampleComponentThree: GKComponent {}
class SampleComponentFour: GKComponent {}

enum Nodes: String, Handle {
    
    case world
    case characters
    case playerSpawnLocation = "PlayerSpawnLocation"
    
    func handle() -> String {
        return self.rawValue
    }
}
