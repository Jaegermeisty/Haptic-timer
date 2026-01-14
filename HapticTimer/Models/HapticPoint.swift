//
//  HapticPoint.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import SwiftData

@Model
final class HapticPoint {
    @Attribute(.unique) var id: UUID
    var triggerSeconds: Int  // Seconds before timer end (e.g., 300 = 5 min mark)
    var patternRawValue: String  // HapticPattern enum raw value
    var isZeroPoint: Bool  // True for the mandatory 0:00 completion point
    var configuration: TimerConfiguration?

    init(triggerSeconds: Int, pattern: HapticPattern, isZeroPoint: Bool = false) {
        self.id = UUID()
        self.triggerSeconds = triggerSeconds
        self.patternRawValue = pattern.rawValue
        self.isZeroPoint = isZeroPoint
    }

    var pattern: HapticPattern {
        get { HapticPattern(rawValue: patternRawValue) ?? .pulse }
        set { patternRawValue = newValue.rawValue }
    }
}
