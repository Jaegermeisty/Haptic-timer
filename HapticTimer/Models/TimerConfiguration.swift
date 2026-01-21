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

    // MARK: - View Model Integration

    /// Create configuration from current timer view model state
    convenience init(name: String, from viewModel: TimerViewModel, colorHex: String = Constants.Colors.defaultOrangeHex) {
        self.init(name: name, durationSeconds: viewModel.totalDurationSeconds, circleColorHex: colorHex)

        // Convert UI haptic points to persistent models
        self.hapticPoints = viewModel.hapticPoints.map { uiPoint in
            let point = HapticPoint(
                triggerSeconds: uiPoint.triggerSeconds,
                pattern: uiPoint.pattern,
                isZeroPoint: uiPoint.isZeroPoint
            )
            point.configuration = self
            return point
        }
    }

    /// Apply this configuration to a timer view model
    func applyTo(_ viewModel: TimerViewModel) {
        // Calculate hours, minutes, seconds from total duration
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = durationSeconds % 60

        // First set duration (this will initialize with a default zero point)
        viewModel.setDuration(hours: hours, minutes: minutes, seconds: seconds)

        // Convert persistent haptic points to UI models
        var loadedPoints = hapticPoints.map { persistentPoint in
            HapticPointUI(
                triggerSeconds: persistentPoint.triggerSeconds,
                pattern: persistentPoint.pattern,
                isZeroPoint: persistentPoint.isZeroPoint
            )
        }

        // Ensure we have a zero point (in case old configurations don't have one)
        if !loadedPoints.contains(where: { $0.isZeroPoint }) {
            loadedPoints.insert(HapticPointUI(triggerSeconds: 0, pattern: .pulse, isZeroPoint: true), at: 0)
        }

        viewModel.hapticPoints = loadedPoints

        // Update last used timestamp
        updateLastUsed()
    }
}
