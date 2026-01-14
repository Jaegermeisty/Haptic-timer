//
//  HapticPattern.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation

enum HapticPattern: String, Codable, CaseIterable {
    case pulse = "pulse"
    case heartbeat = "heartbeat"
    case wave = "wave"
    case staccato = "staccato"
    case rolling = "rolling"
    case alert = "alert"

    var displayName: String {
        self.rawValue.capitalized
    }

    var description: String {
        switch self {
        case .pulse:
            return "One strong, smooth bump"
        case .heartbeat:
            return "Two quick thumps (lub-dub)"
        case .wave:
            return "Rising and falling intensity"
        case .staccato:
            return "Four quick sharp taps"
        case .rolling:
            return "Continuous rumble"
        case .alert:
            return "Three medium pulses"
        }
    }
}
