//
//  CharacterType.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 21/05/2023.
//

import Foundation

extension CharacterBot {
    
    // The various character bot types
    enum CharacterType {
        
        // Characters age
        enum CharacterAge: CaseIterable {
            case young
            case mid
            case senior
            
            static func randomAge() -> CharacterAge {
                return CharacterAge.allCases.randomElement() ?? .mid
            }
        }
        
        // Character type
        case female(CharacterAge)
        case male(CharacterAge)
        case animal(CharacterAge)
        case disabledFemale(CharacterAge)
        case disabledMale(CharacterAge)
        
        static func random() -> CharacterType {
            let age: CharacterAge = CharacterAge.randomAge()
            return Array<CharacterType>([.female(age), .male(age), .animal(age), .disabledFemale(age), .disabledMale(age)]).randomElement() ?? .female(age)
        }
    }
}

