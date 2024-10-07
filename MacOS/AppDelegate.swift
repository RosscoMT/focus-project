//
//  AppDelegate.swift
//  CoffeeHouse (MacOS)
//
//  Created by Ross Viviani on 08/10/2022.
//

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
