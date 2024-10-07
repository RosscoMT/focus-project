//
//  GKComponent+Extension.swift
//  
//
//  Created by Ross Viviani on 09/09/2023.
//

import GameplayKit

extension GKComponent {
    
    public func currentTimeStamp() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}
