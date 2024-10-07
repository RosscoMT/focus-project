//
//  EntityContactType.swift
//
//
//  Created by Ross Viviani on 17/10/2022.
//

import GameplayKit

///  A protocol representing the ability of a `GKEntity` to respond to the start and end of a physics contact with another `GKEntity`.
public protocol EntityContactType {
    func entityContactDidBegin(_ entity: GKEntity)
    func entityContactEntityDidEnd(_ entity: GKEntity)
}
