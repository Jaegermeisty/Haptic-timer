//
//  SaveConfigSheet.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI
import SwiftData

struct SaveConfigSheet: View {
    let viewModel: TimerViewModel
    let modelContext: ModelContext
    let colorHex: String

    @Environment(\.dismiss) private var dismiss
    @State private var configName: String = ""
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        ZStack {
            Constants.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Save Timer Configuration")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top)

                TextField("Timer Name", text: $configName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(10)
                    .focused($isNameFieldFocused)
                    .padding(.horizontal)

                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Constants.Colors.secondaryBackground)
                    .foregroundStyle(.white)
                    .cornerRadius(10)

                    Button("Save") {
                        saveConfiguration()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Constants.Colors.defaultOrange)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .disabled(configName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }

    private func saveConfiguration() {
        let trimmedName = configName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        // Create new configuration from current view model state with selected color
        let config = TimerConfiguration(name: trimmedName, from: viewModel, colorHex: colorHex)

        // Save to SwiftData
        modelContext.insert(config)

        // Dismiss sheet
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TimerConfiguration.self, HapticPoint.self, configurations: config)
    let viewModel = TimerViewModel()
    viewModel.setDuration(hours: 0, minutes: 10, seconds: 0)

    return SaveConfigSheet(
        viewModel: viewModel,
        modelContext: container.mainContext,
        colorHex: Constants.Colors.defaultOrangeHex
    )
}
