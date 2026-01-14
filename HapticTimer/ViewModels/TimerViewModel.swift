//
//  TimerViewModel.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import Combine
import Observation

// MARK: - Haptic Point UI Model
struct HapticPointUI: Identifiable {
    let id: UUID
    var triggerSeconds: Int // Time remaining when this fires (e.g., 300 = fires at 5:00)
    var pattern: HapticPattern
    var isZeroPoint: Bool

    init(triggerSeconds: Int, pattern: HapticPattern = .pulse, isZeroPoint: Bool = false) {
        self.id = UUID()
        self.triggerSeconds = triggerSeconds
        self.pattern = pattern
        self.isZeroPoint = isZeroPoint
    }
}

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
    var hapticPoints: [HapticPointUI] = []

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

        // Always add the mandatory 0:00 point if it doesn't exist
        if hapticPoints.isEmpty || !hapticPoints.contains(where: { $0.isZeroPoint }) {
            hapticPoints = [HapticPointUI(triggerSeconds: 0, pattern: .pulse, isZeroPoint: true)]
        }
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

    // MARK: - Haptic Point Management
    func canAddHapticPoint(isPremium: Bool) -> Bool {
        let customPoints = hapticPoints.filter { !$0.isZeroPoint }.count
        let maxPoints = isPremium ? Constants.Limits.premiumHapticPoints : Constants.Limits.freeHapticPoints
        return customPoints < maxPoints
    }

    func addHapticPoint(isPremium: Bool) {
        guard canAddHapticPoint(isPremium: isPremium) else {
            print("⚠️ Maximum haptic points reached")
            return
        }

        // Generate random position (30-second intervals)
        let maxIntervals = totalDurationSeconds / Constants.Limits.snapInterval
        guard maxIntervals > 1 else { return }

        // Try to find a non-colliding position
        for _ in 0..<10 {
            let randomInterval = Int.random(in: 1..<maxIntervals)
            let triggerSeconds = randomInterval * Constants.Limits.snapInterval

            if canPlacePoint(at: triggerSeconds) {
                let newPoint = HapticPointUI(triggerSeconds: triggerSeconds)
                hapticPoints.append(newPoint)
                return
            }
        }
    }

    func removeHapticPoint(_ point: HapticPointUI) {
        guard !point.isZeroPoint else { return }
        hapticPoints.removeAll { $0.id == point.id }
    }

    func updatePointPosition(_ pointId: UUID, to newSeconds: Int) {
        guard let index = hapticPoints.firstIndex(where: { $0.id == pointId }),
              !hapticPoints[index].isZeroPoint else { return }

        let snappedSeconds = newSeconds.snappedToInterval()
        if canPlacePoint(at: snappedSeconds, excluding: pointId) {
            hapticPoints[index].triggerSeconds = snappedSeconds
        }
    }

    func updatePointPattern(_ pointId: UUID, to pattern: HapticPattern) {
        guard let index = hapticPoints.firstIndex(where: { $0.id == pointId }) else { return }
        hapticPoints[index].pattern = pattern
    }

    private func canPlacePoint(at seconds: Int, excluding pointId: UUID? = nil) -> Bool {
        // Check if too close to timer end (must be at least 30 seconds before end)
        guard seconds <= totalDurationSeconds - Constants.Limits.minimumPointSpacing || seconds == 0 else {
            return false
        }

        // Check collision with other points
        for point in hapticPoints where point.id != pointId {
            let distance = abs(point.triggerSeconds - seconds)
            if distance < Constants.Limits.minimumPointSpacing {
                return false
            }
        }

        return true
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
