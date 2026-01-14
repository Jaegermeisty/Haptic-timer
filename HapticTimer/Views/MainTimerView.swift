//
//  MainTimerView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct MainTimerView: View {
    @Environment(PurchaseState.self) private var purchaseState
    @State private var viewModel = TimerViewModel()
    @State private var hours: Int = 0
    @State private var minutes: Int = 10
    @State private var seconds: Int = 0
    @State private var showingTimePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Circle with time in center
                    CircleProgressView(
                        progress: viewModel.progress,
                        remainingTime: viewModel.remainingSeconds,
                        color: Constants.Colors.defaultOrange,
                        isTimerRunning: viewModel.isRunning,
                        onTimeTap: {
                            if !viewModel.isRunning {
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
                syncPickerToViewModel()
            } content: {
                TimePickerSheet(
                    hours: $hours,
                    minutes: $minutes,
                    seconds: $seconds
                )
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                syncViewModelToPicker()
            }
        }
    }

    private var timerControls: some View {
        HStack(spacing: 16) {
            if viewModel.isRunning {
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
            } else if viewModel.isPaused {
                Button(action: resumeTimer) {
                    Text("Resume")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.defaultOrange)
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

    // MARK: - Actions
    private func startTimer() {
        viewModel.setDuration(hours: hours, minutes: minutes, seconds: seconds)
        viewModel.start()
    }

    private func pauseTimer() {
        viewModel.pause()
    }

    private func resumeTimer() {
        viewModel.resume()
    }

    private func resetTimer() {
        viewModel.reset()
        syncViewModelToPicker()
    }

    // MARK: - Sync helpers
    private func syncViewModelToPicker() {
        viewModel.setDuration(hours: hours, minutes: minutes, seconds: seconds)
    }

    private func syncPickerToViewModel() {
        // When sheet dismisses, update ViewModel with new picker values
        viewModel.setDuration(hours: hours, minutes: minutes, seconds: seconds)
    }
}

#Preview {
    MainTimerView()
        .environment(PurchaseState())
}
