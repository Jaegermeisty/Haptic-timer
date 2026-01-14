//
//  SavedTimersView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI
import SwiftData

struct SavedTimersView: View {
    @Environment(PurchaseState.self) private var purchaseState
    @Environment(TimerCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimerConfiguration.lastUsedAt, order: .reverse) private var configurations: [TimerConfiguration]

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()

                if !purchaseState.isPremium {
                    // Paywall for free users
                    PaywallView()
                } else {
                    // Configuration list for premium users
                    configurationsList
                }
            }
            .navigationTitle("Saved Timers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var configurationsList: some View {
        Group {
            if configurations.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(configurations) { config in
                        Button(action: {
                            loadConfiguration(config)
                        }) {
                            configurationRow(config)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteConfigurations)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text("No Saved Timers Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Tap + to save your first\ntimer configuration")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }

    private func configurationRow(_ config: TimerConfiguration) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: config.circleColorHex))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(config.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text(config.durationSeconds.formattedTime())
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)

                Text("\(config.hapticPoints.count) haptic points")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .listRowBackground(Constants.Colors.secondaryBackground)
    }

    private func deleteConfigurations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(configurations[index])
        }
    }

    private func loadConfiguration(_ config: TimerConfiguration) {
        coordinator.loadConfiguration(config)
    }
}

#Preview {
    SavedTimersView()
        .environment(PurchaseState())
        .modelContainer(for: [TimerConfiguration.self, HapticPoint.self], inMemory: true)
}
