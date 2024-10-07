//
//  GeneralTools.swift
//  
//
//  Created by Ross Viviani on 26/05/2023.
//

import GameplayKit

public struct GeneralTools {
    
    public struct ProcessCodeDataModel<T: GKState> {
        let state: T.Type
        let code: () -> Void
        
        public init(state: T.Type, code: @escaping () -> Void) {
            self.state = state
            self.code = code
        }
    }
    
    /// Calculates the time that has elapsed
    static public func timeElapsed(timeStamp: TimeInterval, wait: Double) -> Bool {
        let time = (Date().timeIntervalSince1970 - timeStamp)
        let remaining = time.truncatingRemainder(dividingBy: 60)
        return remaining > wait
    }
    
    // Calculate remaining time
    static public func timeElapsed(timeStamp: TimeInterval) -> TimeInterval {
        let time = (Date().timeIntervalSince1970 - timeStamp)
        return time.truncatingRemainder(dividingBy: 60)
    }
    
    /// Executes state specific code
    static public func processCodeInState(currentMachineState: GKStateMachine, data: [ProcessCodeDataModel<GKState>]) {
  
        if let data = data.first(where: {NSStringFromClass($0.state) == String(describing: currentMachineState.currentState)}) {
            data.code()
        } else {
            return
        }
    }
    
    /// Calculate a snap effect
    /// - Parameters:
    ///   - step: The amount the movement should snap to
    ///   - position: The current position
    /// - Returns: The new calculated position
    static public func snapToPoint(step: CGFloat, position: CGPoint) -> CGPoint {
        return .init(x: step * floor((position.x / step)),
                     y: step * floor((position.y / step)))
    }
    
    /// Convenience method for generating a generic type random number between two numbers, using the gameplaykit engine
    /// - Parameters:
    ///   - lowest: What is the lowest number to use?
    ///   - highest: What is the highest number to use?
    /// - Returns: The result
    static public func randomNumberInRange<T: Numeric>(lowest: Int, highest: Int) -> T {
        let random: GKRandomDistribution = GKRandomDistribution(lowestValue: lowest, highestValue: highest)
        
        if let value = T.init(exactly: random.nextInt()) {
            return value
        } else {
            fatalError("UNSUPPORTED DATA TYPE")
        }
    }
    
    /// Generates timestamp which can be used anywhere - helps to enforce using timeIntervalSince1970 (avoid potential issues of conflicting time approaches)
    static public func currentTimeStamp() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}

/// Sets up a mode to store the seconds to wait and timestamp which will be initialised upon need
public struct AdvanceInTimeByModel: Equatable {
    public let seconds: Double
    public var timestamp: TimeInterval?
    
    public init(seconds: Double, timestamp: TimeInterval? = nil) {
        self.seconds = seconds
        self.timestamp = timestamp
    }
}
