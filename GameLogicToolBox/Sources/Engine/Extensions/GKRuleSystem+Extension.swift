//
//  GKRuleSystem+Extension.swift
//  
//
//  Created by Ross Viviani on 07/09/2023.
//

import GameplayKit

public enum RulesOutcome: Equatable {
    case proceed
    case passed(test: String)
    case fail
    
    public func handle() -> NSString {
        switch self {
        case .proceed:
            return "proceed"
        case .passed(let test):
            return NSString(string: "\(test) - Passed")
        case .fail:
            return "fail"
        }
    }
}

extension GKRuleSystem {
    
    
    /// Evaluates the current set of rules
    /// - Parameters:
    ///   - state: The current state of the entity
    ///   - rules: The rules to be evaluated against
    /// - Returns: Returns the outcome
    public func evaluate(state: [String: Any], rules: [GKRule]) -> RulesOutcome {
        
        // Reset system before processing
        self.reset()
        
        // Fresh start
        self.removeAllRules()
        
        // Add rules to process
        self.add(rules)
        
        // Add state information
        self.state.addEntries(from: state)
        
        // Evaluate rules
        self.evaluate()
        
        // Return fact and outcome
        if self.facts.count == rules.count {
            return .proceed
        } else {
            return .fail
        }
    }
}
