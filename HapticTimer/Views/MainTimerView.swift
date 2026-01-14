//
//  MainTimerView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct MainTimerView: View {
    @Environment(PurchaseState.self) private var purchaseState
    @State private var hours: Int = 0
    @State private var minutes: Int = 10
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false

    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Circle and Time Display
                    CircleProgressView(
                        progress: 1.0,
                        remainingTime: totalSeconds,
                        color: Constants.Colors.defaultOrange
                    )

                    Spacer()

                    // Duration Picker (shown when timer stopped)
                    if !isTimerRunning {
                        durationPicker
                    }

                    Spacer()

                    // Timer Controls
                    timerControls

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("HapticTimer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var durationPicker: some View {
        HStack(spacing: 8) {
            Picker("Hours", selection: $hours) {
                ForEach(0..<24) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text(":")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            Picker("Minutes", selection: $minutes) {
                ForEach(0..<60) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text(":")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            Picker("Seconds", selection: $seconds) {
                ForEach(0..<60) { second in
                    Text(String(format: "%02d", second)).tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
        }
        .frame(height: 150)
    }

    private var timerControls: some View {
        HStack(spacing: 16) {
            if isTimerRunning {
                Button(action: pauseTimer) {
                    Text("Pause")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.secondaryBackground)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }

                Button(action: resetTimer) {
                    Text("Reset")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.secondaryBackground)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
            } else {
                Button(action: startTimer) {
                    Text("Start")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.defaultOrange)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }

    private func startTimer() {
        guard totalSeconds >= Constants.Timer.minimumDuration else { return }
        isTimerRunning = true
    }

    private func pauseTimer() {
        isTimerRunning = false
    }

    private func resetTimer() {
        isTimerRunning = false
    }
}

#Preview {
    MainTimerView()
        .environment(PurchaseState())
}
