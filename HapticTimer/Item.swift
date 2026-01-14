//
//  Item.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 13/01/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
