//
//  TimerCoordinator.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import Observation

/// Coordinates timer configuration loading across tabs
@Observable
class TimerCoordinator {
    var configurationToLoad: TimerConfiguration?
    var shouldSwitchToTimerTab: Bool = false

    func loadConfiguration(_ config: TimerConfiguration) {
        configurationToLoad = config
        shouldSwitchToTimerTab = true
    }

    func clearPendingLoad() {
        configurationToLoad = nil
        shouldSwitchToTimerTab = false
    }
}
