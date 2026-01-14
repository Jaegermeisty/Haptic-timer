//
//  TimerConfiguration.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import SwiftData

@Model
final class TimerConfiguration {
    @Attribute(.unique) var id: UUID
    var name: String
    var durationSeconds: Int
    var circleColorHex: String
    var createdAt: Date
    var lastUsedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HapticPoint.configuration)
    var hapticPoints: [HapticPoint]

    init(name: String, durationSeconds: Int, circleColorHex: String = "FF8C42") {
        self.id = UUID()
        self.name = name
        self.durationSeconds = durationSeconds
        self.circleColorHex = circleColorHex
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.hapticPoints = []
    }

    func updateLastUsed() {
        self.lastUsedAt = Date()
    }
}
