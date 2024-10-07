//
//  PhysicsBody.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 17/12/2022.
//

import SpriteKit
import GameplayKit

// Physics Categories for the game
enum PhysicsCategory: String {
    
    struct PhysicsBody {
        let bodySize: CGSize
        let point: CGPoint
    }
    
    case player
    case wall
    case door
    case furniture
    case customer
    case secondaryFurniture
    
    // Generate the physics body and positiom
    func rectBody(size: CGSize, frame: CGRect) -> PhysicsBody {
        
        switch self {
        case .player, .door, .secondaryFurniture, .furniture, .wall:
            return .init(bodySize: size, point: .zero)
        case .customer:
            return .init(bodySize: .init(width: size.width / 2,
                                     height: (size.height / 3)),
                         point: .init(x: frame.midX, y: (frame.minY + 20) + frame.midY / 2))
        }
    }
}

enum PhysicsShape: String {
    case circle
    case rect
}

struct PhysicsBody: OptionSet, Hashable {
    
    static let player     = PhysicsBody(rawValue: 1 << 0)
    static let wall       = PhysicsBody(rawValue: 1 << 1)
    static let door       = PhysicsBody(rawValue: 1 << 2)
    static let furniture  = PhysicsBody(rawValue: 1 << 3)
    static let customer   = PhysicsBody(rawValue: 1 << 4)
    static let secondaryFurniture  = PhysicsBody(rawValue: 1 << 5)
    
    let rawValue: UInt32
    
    static var collisions: [PhysicsBody: [PhysicsBody]] = [
        .player: [.wall, .door, .furniture, .customer, .secondaryFurniture],
        .customer: [.wall, .player, .furniture, .secondaryFurniture, .door],
        .furniture: [.wall]
    ]
    
    static var contactTests: [PhysicsBody: [PhysicsBody]] = [
        .customer: [.wall, .secondaryFurniture, .furniture]
    ]
    
    var categoryBitMask: UInt32 {
        return rawValue
    }
    
    var collisionBitMask: UInt32 {
        
        let bitMask = PhysicsBody.collisions[self]?.reduce(PhysicsBody(), { result, physicsBody in
            return result.union(physicsBody)
        })
        
        return bitMask?.rawValue ?? 0
    }
    
    var contactTestBitMask: UInt32 {
        
        let bitMask = PhysicsBody.contactTests[self]?.reduce(PhysicsBody(), { result, physicsBody in
            return result.union(physicsBody)
        })
        
        return bitMask?.rawValue ?? 0
    }
    
    static func forType(_ type: PhysicsCategory?) -> PhysicsBody? {
        switch type {
        case .player:
            return self.player
        case .wall:
            return self.wall
        case .door:
            return self.door
        case .furniture:
            return self.furniture
        case .customer:
            return self.customer
        case .secondaryFurniture:
            return self.secondaryFurniture
        case .none:
            break
        }
        
        return nil
    }
}
