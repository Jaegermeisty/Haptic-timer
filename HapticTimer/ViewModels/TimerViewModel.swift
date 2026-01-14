//
//  TimerViewModel.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import Combine
import Observation

@Observable
class TimerViewModel {
    // MARK: - State
    enum TimerState {
        case idle
        case running
        case paused
        case completed
    }

    var state: TimerState = .idle
    var remainingSeconds: Int = 0 // For display
    var totalDurationSeconds: Int = 0

    // MARK: - Private Properties
    private var timerCancellable: AnyCancellable?
    private var endDate: Date?
    private var remainingTime: TimeInterval = 0 // For smooth progress animation

    // MARK: - Computed Properties
    var progress: Double {
        guard totalDurationSeconds > 0 else { return 0 }
        // Use fractional time for smooth animation
        return remainingTime / Double(totalDurationSeconds)
    }

    var isRunning: Bool {
        state == .running
    }

    var isPaused: Bool {
        state == .paused
    }

    // MARK: - Timer Control
    func setDuration(hours: Int, minutes: Int, seconds: Int) {
        let total = hours * 3600 + minutes * 60 + seconds
        totalDurationSeconds = total
        remainingSeconds = total
        remainingTime = TimeInterval(total)
    }

    func start() {
        guard remainingSeconds >= Constants.Timer.minimumDuration else {
            print("⚠️ Duration too short: \(remainingSeconds)s (minimum: \(Constants.Timer.minimumDuration)s)")
            return
        }

        state = .running
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        startCountdown()
    }

    func pause() {
        state = .paused
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        startCountdown()
    }

    func reset() {
        state = .idle
        timerCancellable?.cancel()
        timerCancellable = nil
        remainingSeconds = totalDurationSeconds
        remainingTime = TimeInterval(totalDurationSeconds)
        endDate = nil
    }

    // MARK: - Private Methods
    private func startCountdown() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRemainingTime()
            }
    }

    private func updateRemainingTime() {
        guard let endDate = endDate else { return }

        let now = Date()
        let remaining = endDate.timeIntervalSince(now)

        if remaining <= 0 {
            // Timer completed
            complete()
        } else {
            remainingTime = remaining // Fractional time for smooth animation
            remainingSeconds = Int(ceil(remaining)) // Integer for display
        }
    }

    private func complete() {
        state = .completed
        remainingSeconds = 0
        remainingTime = 0
        timerCancellable?.cancel()
        timerCancellable = nil

        // Auto-reset after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if self?.state == .completed {
                self?.reset()
            }
        }
    }

    // MARK: - Cleanup
    deinit {
        timerCancellable?.cancel()
    }
}
