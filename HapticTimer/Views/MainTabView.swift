//
//  MainTabView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(PurchaseState.self) private var purchaseState

    var body: some View {
        TabView {
            MainTimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            SavedTimersView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(PurchaseState())
        .modelContainer(for: [TimerConfiguration.self, HapticPoint.self], inMemory: true)
}
