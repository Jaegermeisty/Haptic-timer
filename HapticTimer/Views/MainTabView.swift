//
//  MainTabView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(PurchaseState.self) private var purchaseState
    @State private var coordinator = TimerCoordinator()
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MainTimerView()
                .environment(coordinator)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)

            SavedTimersView()
                .environment(coordinator)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(1)
        }
        .onChange(of: coordinator.shouldSwitchToTimerTab) { _, shouldSwitch in
            if shouldSwitch {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(PurchaseState())
        .modelContainer(for: [TimerConfiguration.self, HapticPoint.self], inMemory: true)
}
