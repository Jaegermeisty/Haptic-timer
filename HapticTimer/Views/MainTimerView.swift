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
    @State private var showingTimePicker = false

    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Circle with time in center
                    CircleProgressView(
                        progress: 1.0,
                        remainingTime: totalSeconds,
                        color: Constants.Colors.defaultOrange,
                        isTimerRunning: isTimerRunning,
                        onTimeTap: {
                            if !isTimerRunning {
                                showingTimePicker = true
                            }
                        }
                    )

                    Spacer()

                    // Timer Controls
                    timerControls
                        .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTimePicker) {
                TimePickerSheet(
                    hours: $hours,
                    minutes: $minutes,
                    seconds: $seconds
                )
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
            }
        }
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
