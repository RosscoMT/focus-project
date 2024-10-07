//
//  GameToolBarOptions.swift
//  CoffeeHouse
//
//  Created by Ross Viviani on 07/05/2022.
//

import UIKit

enum GameToolBarOptions: String, CaseIterable {
    case items
    case help
    case save
    case hide
    
    func attachedActions() {
        switch self {
        case .items:
            NotificationCenter.default.post(name: Notification.Name("OpenItems"), object: nil, userInfo: nil)
        case .help:
            NotificationCenter.default.post(name: Notification.Name("OpenItems"), object: nil, userInfo: nil)
        case .save:
            NotificationCenter.default.post(name: Notification.Name("OpenItems"), object: nil, userInfo: nil)
        case .hide:
            NotificationCenter.default.post(name: Notification.Name("OpenItems"), object: nil, userInfo: nil)
        }
    }
}
