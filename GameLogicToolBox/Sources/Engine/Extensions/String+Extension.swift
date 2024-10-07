//
//  String+Extension.swift
//  
//
//  Created by Ross Viviani on 27/04/2023.
//

import Foundation

public extension String {
    
    // Upper cases the first character of a string
    func captializeString() -> Self {
        
        // Prevent captializing empty strings
        guard self.isEmpty == false, self.count > 1 else {
            return self
        }
    
        return "\(self.first?.uppercased() ?? "")" + self.dropFirst()
    }
}
