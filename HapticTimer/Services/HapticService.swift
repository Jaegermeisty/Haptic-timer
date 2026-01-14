//
//  HapticService.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import CoreHaptics

class HapticService {
    static let shared = HapticService()

    private var engine: CHHapticEngine?
    private var isEngineRunning = false

    private init() {
        prepareHaptics()
    }

    // MARK: - Setup

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Device does not support haptics")
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
            isEngineRunning = true

            // Reset handler if engine stops
            engine?.stoppedHandler = { [weak self] reason in
                print("⚠️ Haptic engine stopped: \(reason)")
                self?.isEngineRunning = false
            }

            // Reset handler
            engine?.resetHandler = { [weak self] in
                print("♻️ Haptic engine reset")
                do {
                    try self?.engine?.start()
                    self?.isEngineRunning = true
                } catch {
                    print("❌ Failed to restart haptic engine: \(error)")
                }
            }

        } catch {
            print("❌ Failed to create haptic engine: \(error)")
        }
    }

    // MARK: - Public Interface

    func playPattern(_ pattern: HapticPattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Haptics not supported - cannot play pattern")
            return
        }

        // Restart engine if needed
        if !isEngineRunning {
            do {
                try engine?.start()
                isEngineRunning = true
            } catch {
                print("❌ Failed to start haptic engine: \(error)")
                return
            }
        }

        do {
            let events = createEvents(for: pattern)
            let hapticPattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: hapticPattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("❌ Failed to play haptic pattern: \(error)")
        }
    }

    // MARK: - Pattern Creation

    private func createEvents(for pattern: HapticPattern) -> [CHHapticEvent] {
        switch pattern {
        case .pulse:
            return createPulsePattern()
        case .heartbeat:
            return createHeartbeatPattern()
        case .wave:
            return createWavePattern()
        case .staccato:
            return createStaccatoPattern()
        case .rolling:
            return createRollingPattern()
        case .alert:
            return createAlertPattern()
        }
    }

    // MARK: - Pattern Implementations

    /// Single strong pulse - One smooth bump like a heartbeat thump
    private func createPulsePattern() -> [CHHapticEvent] {
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0,
            duration: 0.5
        )
        return [event]
    }

    /// Two quick thumps (lub-dub) like a heartbeat
    private func createHeartbeatPattern() -> [CHHapticEvent] {
        let thump1 = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ],
            relativeTime: 0,
            duration: 0.15
        )

        let thump2 = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ],
            relativeTime: 0.3,
            duration: 0.2
        )

        return [thump1, thump2]
    }

    /// Rising then falling intensity like an ocean wave
    private func createWavePattern() -> [CHHapticEvent] {
        var events: [CHHapticEvent] = []

        // Create a wave effect with multiple events
        let steps = 20
        let duration = 2.0
        let stepDuration = duration / Double(steps)

        for i in 0..<steps {
            let progress = Double(i) / Double(steps)
            // Create sine wave for smooth rise and fall
            let intensity = sin(progress * .pi) * 0.7 + 0.3

            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: Double(i) * stepDuration,
                duration: stepDuration
            )
            events.append(event)
        }

        return events
    }

    /// Four quick sharp taps - Tap-tap-tap-tap
    private func createStaccatoPattern() -> [CHHapticEvent] {
        let taps: [CHHapticEvent] = (0..<4).map { index in
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: Double(index) * 0.3
            )
        }
        return taps
    }

    /// Continuous rumble with slight variation
    private func createRollingPattern() -> [CHHapticEvent] {
        var events: [CHHapticEvent] = []

        // Create continuous rumble with variations
        let segments = 5
        let totalDuration = 2.5
        let segmentDuration = totalDuration / Double(segments)

        for i in 0..<segments {
            let intensity = Float.random(in: 0.6...0.8)

            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: Double(i) * segmentDuration,
                duration: segmentDuration
            )
            events.append(event)
        }

        return events
    }

    /// Three medium pulses with spacing - Bump... bump... bump
    private func createAlertPattern() -> [CHHapticEvent] {
        let pulses: [CHHapticEvent] = (0..<3).map { index in
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: Double(index) * 0.6,
                duration: 0.3
            )
        }
        return pulses
    }

    // MARK: - Cleanup

    deinit {
        engine?.stop()
    }
}
