//
//  Data+Extension.swift
//
//
//  Created by Ross Viviani on 21/09/2022.
//  Copyright © 2022 Apple, Inc. All rights reserved.
//

import Foundation

public extension Data {
    
    /// Decode Plist data information
    static func decodePlistData<T: Decodable>(url: URL) throws -> T {
        let data: Data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(T.self, from: data)
    }
}
