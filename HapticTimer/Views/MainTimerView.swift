//
//  MainTimerView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI
import SwiftData

struct MainTimerView: View {
    @Environment(PurchaseState.self) private var purchaseState
    @Environment(TimerCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TimerViewModel()
    @State private var hours: Int = 0
    @State private var minutes: Int = 10
    @State private var seconds: Int = 0
    @State private var showingTimePicker = false
    @State private var selectedPoint: HapticPointUI?
    @State private var showingSaveSheet = false
    @State private var showingColorPicker = false
    @State private var selectedColorHex: String = Constants.Colors.defaultOrangeHex

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
                        totalDuration: viewModel.totalDurationSeconds,
                        color: Color(hex: selectedColorHex),
                        isTimerRunning: viewModel.isRunning,
                        hapticPoints: viewModel.hapticPoints,
                        onTimeTap: {
                            if !viewModel.isRunning {
                                showingTimePicker = true
                            }
                        },
                        onPointTap: { point in
                            handlePointTap(point)
                        },
                        onPointDrag: { point, newSeconds in
                            handlePointDrag(point, to: newSeconds)
                        }
                    )

                    Spacer()

                    // Add Haptic Point and Color Buttons
                    if !viewModel.isRunning {
                        HStack(spacing: 12) {
                            addPointButton

                            if purchaseState.isPremium {
                                colorPickerButton
                            }
                        }
                        .padding(.bottom, 16)
                    }

                    // Timer Controls
                    timerControls
                        .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.isRunning && purchaseState.isPremium {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingSaveSheet = true }) {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
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
            .sheet(item: $selectedPoint) { point in
                PatternSelectorSheet(
                    point: point,
                    onSelect: { pattern in
                        viewModel.updatePointPattern(point.id, to: pattern)
                    },
                    onDelete: {
                        viewModel.removeHapticPoint(point)
                    },
                    onPreview: { pattern in
                        HapticService.shared.playPattern(pattern)
                    }
                )
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingSaveSheet) {
                SaveConfigSheet(viewModel: viewModel, modelContext: modelContext, colorHex: selectedColorHex)
                    .presentationDetents([.height(200)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerSheet(
                    currentColorHex: selectedColorHex,
                    onSelect: { hex in
                        selectedColorHex = hex
                    }
                )
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                syncViewModelToPicker()
            }
            .onChange(of: coordinator.configurationToLoad) { _, config in
                if let config = config {
                    loadConfiguration(config)
                    coordinator.clearPendingLoad()
                }
            }
        }
    }

    private var addPointButton: some View {
        Button(action: addHapticPoint) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Vibration Point")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(viewModel.canAddHapticPoint(isPremium: purchaseState.isPremium) ? .white : .gray)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(10)
        }
        .disabled(!viewModel.canAddHapticPoint(isPremium: purchaseState.isPremium))
    }

    private var colorPickerButton: some View {
        Button(action: { showingColorPicker = true }) {
            Circle()
                .fill(Color(hex: selectedColorHex))
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                )
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

    private func addHapticPoint() {
        if !viewModel.canAddHapticPoint(isPremium: purchaseState.isPremium) && !purchaseState.isPremium {
            // TODO: Show paywall
            print("Show paywall - reached free limit")
            return
        }
        viewModel.addHapticPoint(isPremium: purchaseState.isPremium)
    }

    private func handlePointTap(_ point: HapticPointUI) {
        selectedPoint = point
    }

    private func handlePointDrag(_ point: HapticPointUI, to newSeconds: Int) {
        viewModel.updatePointPosition(point.id, to: newSeconds)
    }

    private func loadConfiguration(_ config: TimerConfiguration) {
        // Stop any running timer first
        if viewModel.isRunning {
            viewModel.reset()
        }

        // Apply configuration to view model
        config.applyTo(viewModel)

        // Update picker values
        hours = viewModel.totalDurationSeconds / 3600
        minutes = (viewModel.totalDurationSeconds % 3600) / 60
        seconds = viewModel.totalDurationSeconds % 60

        // Load color
        selectedColorHex = config.circleColorHex
    }
}

#Preview {
    MainTimerView()
        .environment(PurchaseState())
}
