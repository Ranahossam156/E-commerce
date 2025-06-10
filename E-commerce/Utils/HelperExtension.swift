//
//  helperExtension.swift
//  E-commerce
//
//  Created by MacBook on 08/06/2025.
//

import Foundation

extension String {
    var capitalizingFirstLetterOnly: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst().lowercased()
    }
}

