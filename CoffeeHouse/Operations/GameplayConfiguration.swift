//
//  GameplayConfiguration.swift
//
//
//  Created by Ross Viviani on 18/12/2022.
//

import Foundation
import CoreGraphics
import Engine
import SpriteKit

/// Configuration information and parameters for the coffee house gameplay.
struct GameplayConfiguration {
    
    struct Debug {
        
        // List of the current settings
        enum Setting {
            case enableLogging
            case enableInformation
            case enableTools
            case showPath
            case simulateScene
            case enableAudio
            case enablePause
            case displayInteractionPad
            case displayPlottedQueue
            case enableStateLog
            case enablePlayerSpawning
        }
    
        // Scene Manager
        static let scene: SceneIdentifier = .gameLevel(0)
        
        // Level settings
        static let enableLogging: Bool = true
        static let enableInformation: Bool = true
        static let simulateScene: Bool = false
        static let enablePause: Bool = false
        static let enableTools: Bool = false
        static let showPath: Bool = false
        static let enableAudio: Bool = false
        static let displayInteractionPad: Bool = false
        static let displayPlottedQueue: Bool = false
        static let enableStateLog: Bool = false
        static let enablePlayerSpawning: Bool = true
        
        static var spawnCounter = -1
        
        
        // Return if setting is enabled
        static func settingEnabled(type: Setting) -> Bool {
            
            switch type {
            case .enableLogging:
                return enableLogging
            case .enableInformation:
                return enableInformation
            case .enableTools:
                return enableTools
            case .showPath:
                return showPath
            case .simulateScene:
                return simulateScene
            case .enableAudio:
                return enableAudio
            case .enablePause:
                return enablePause
            case .displayInteractionPad:
                return displayInteractionPad
            case .displayPlottedQueue:
                return displayPlottedQueue
            case .enableStateLog:
                return enableStateLog
            case .enablePlayerSpawning:
                return enablePlayerSpawning
            }
        }
    }
    
    struct PlayerBot {
        
        // These are the animation identifers for the character
        enum AnimationIdentifer: String {
            case idle = "PlayerBotIdle"
            case walking = "PlayerBotWalk"
        }
        
        // The different animation states that an animated character can be in.
        enum state: String {
            case idle = "Idle"
            case walkForward = "WalkForward"
            case walkBackward = "WalkBackward"
        }
        
        // The movement speed (in points per second) for the `PlayerBot`.
        static let movementSpeed: CGFloat = 210.0

        // The angular rotation speed (in radians per second) for the `PlayerBot`.
        static let angularSpeed: CGFloat = CGFloat(Double.pi) * 1.4
        
        // The radius of the `PlayerBot`'s physics body.
        static var physicsBodyRadius: CGFloat = 30.0
        
        // The offset of the `PlayerBot`'s physics body's center from the `PlayerBot`'s center.
        static let physicsBodyOffset: CGPoint = CGPoint(x: 0.0, y: -25.0)
        
        // The radius of the agent associated with this `PlayerBot` for pathfinding.
        static let agentRadius: Float = Float(physicsBodyRadius)
        
        // The offset of the agent's center from the `PlayerBot`'s center.
        static let agentOffset: CGPoint = physicsBodyOffset

        // The amount of time it takes the `PlayerBot` to appear in a level before becoming controllable by the player.
        static let appearDuration: TimeInterval = 0.50
    }

    struct CharacterBot: GameConfigDelegate {
    
        // These are the animation identifers for the character
        enum CharacterAnimationIdentifer: String {
            case idle = "CharacterBotIdle"
            case walking = "CharacterBotWalk"
            case sit = "CharacterBotSit"
        }
        
        static let mass: Float = 1
        static let maxAcceleration: Float = 180
        static let maxSpeed: Float = 230
        
        static func settingModel() -> Factory.FactoryAgent {
            return .init(mass: CharacterBot.mass, maxAcceleration: CharacterBot.maxAcceleration, maxSpeed: CharacterBot.maxSpeed)
        }
    }
    
    struct Level {
        
        static let cameraEdgeBounds: CGFloat = 100
        static let appMenuMargine: CGFloat = 50
        
        static let baseExtension = "//world"
        
        // Custom default values for the games background audio
        static let backgroundMusicDelay: Double = 1.0
        static let initialVolume: Float = 0.5
        static let initialVolumeActionDuration: Double = 1.5
        
        static let pathwayObstaclesMargin: Double = 50
        
        // Exiting scene
        static let exitMoveBy: Double = 500
        static let exitMoveDuration: Double = 3
        static let exitSceneTime: Double = 500
        static let exitWaitTime: Double = 1
        static let exitFadoutTime: Double = 1
        
        // Editor mode
        static let snapMeasurement: CGFloat = 10
        static let snapMovementDelay: CGFloat = 0.05
        
        struct Furniture {
            
            // The colour of the boundary box
            static let boundaryBoxEnabled: SKColor = .green.withAlphaComponent(0.3)
            static let boundaryBoxDisabled: SKColor = .red.withAlphaComponent(0.3)
        }
        
        // In level NPC settings
        struct NPC {
            
            // Production - Waiting times for NPC's in the queue
            static let lowestQueueTime: Int = 5
            static let highestQueueTime: Int = 60
            
            // Development - Waiting times for NPC's in the queue
            static let devLowestQueueTime: Int = 5
            static let devHighestQueueTime: Int = 15
            
            static let pathRadius: Float = 5
        }
    }
    
    struct GeneralControls {
        
        // The speed in which the panning action should move the camera
        static let panningSpeed: CGFloat = 0.6
        static let minimumZoom: CGFloat = 0.5
        static let maximumZoom: CGFloat = 2.5
        static let zoomRate: CGFloat = 0.3
    }
    
    struct TouchControl {
        // The minimum distance a virtual thumbstick must move before it is considered to have been moved.
        static let minimumRequiredThumbstickDisplacement: Float = 0.35
        
        // The minimum size for an on-screen control.
        static let minimumControlSize: CGFloat = 140
        
        // The ideal size for an on-screen control as a ratio of the scene's width.
        static let idealRelativeControlSize: CGFloat = 0.15
    }
    
    struct Keyboard {
        
        // The minimum distance a virtual thumbstick must move before it is considered to have been moved.
        static let longPressDuration: TimeInterval = 0.8
        static let doubleTapDuration: TimeInterval = 0.8
        
        // To improve the architecture of the game, some logic is being replaced to allow for greater game customisation, clarity and accessibility.
        enum Controls: String {
            
            typealias SpecialKey = KeyboardControls.SpecialKeys
            
            // MARK: Directional keys
    
            case w
            case s
            case a
            case d
            
            case up
            case down
            case left
            case right
            
            // MARK: Action keys
            
            case p
            
            // MARK: Debug keys
            
            case togglePhysics = "["
            case toggleInfo = ";"
            
            
            // MARK: Variables
            
            var character: Character {
                
                switch self {
                case .up:
                    return Character(UnicodeScalar(SpecialKey.up.rawValue)!)
                case .down:
                    return Character(UnicodeScalar(SpecialKey.down.rawValue)!)
                case .left:
                    return Character(UnicodeScalar(SpecialKey.left.rawValue)!)
                case .right:
                    return Character(UnicodeScalar(SpecialKey.right.rawValue)!)
                default:
                    return Character(self.rawValue.unicodeScalars.first!)
                }
            }
            
            /// Returns direction associated with pressed key
            /// - Parameter key: The character which was pressed on the keyboard
            /// - Returns: Returns the associated direction for key if correct
            static func direction(_ key: Character) -> SIMD2<Float>? {
                
                switch key {
                case Controls.up.character, Controls.w.character:
                    return KeyboardControls.forward.vector()
                case Controls.down.character, Controls.s.character:
                    return KeyboardControls.backward.vector()
                case Controls.left.character, Controls.a.character:
                    return KeyboardControls.counterClockwise.vector()
                case Controls.right.character, Controls.d.character:
                    return KeyboardControls.clockwise.vector()
                default:
                    return nil
                }
            }
            
            
            /// Returns action associated with pressed key
            /// - Parameter key: The character which was pressed on the keyboard
            /// - Returns: Returns the associated action key if present
            static func actionKey(_ key: Character) -> Controls? {
                 
                switch key {
                case Controls.p.character:
                    return .p
                case Controls.toggleInfo.character:
                    return .toggleInfo
                case Controls.togglePhysics.character:
                    return .togglePhysics
                default:
                    return nil
                }
            }
        }
    }
    
    struct SceneManager {
        // The duration of a transition between loaded scenes.
        static let transitionDuration: TimeInterval = 1.5
        
        // The duration of a transition from the progress scene to its loaded scene.
        static let progressSceneTransitionDuration: TimeInterval = 0.5
    }
    
    struct InGameMenu {
        static var animationDuration: CGFloat = 0.3
        static var menuFadeDuraction: CGFloat = 0.15
    }
    
    struct ProgressScene {
        static var progressBarAnimationDuration: CGFloat = 0.3
    }
    
    struct GUI {
        static let enabledButton: SKColor = .init(red: 0.20, green: 0.84, blue: 0.29, alpha: 1.00)
        static let disabledButton: SKColor = .gray
    }
}
