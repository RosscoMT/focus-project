//
//  Notifications+Extension.swift
//  DemoBots
//
//  Created by Ross Viviani on 01/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation

public extension Notification.Name {
    
    // Game loading notifications - Scene Manager
    static let sceneLoaderDidComplete = Notification.Name(rawValue: "SceneLoaderDidCompleteNotification")
    static let requiredSceneLoaderDidComplete = Notification.Name(rawValue: "RequiredSceneLoaderDidCompleteNotification")
    static let sceneLoaderDidFail = Notification.Name(rawValue: "SceneLoaderDidFailNotification")
    static let progressAnimationsCompleted = Notification.Name(rawValue: "ProgressAnimationsCompleted")
    static let sceneLoaderUpdate = Notification.Name(rawValue: "SceneLoaderUpdateNotification")
}
