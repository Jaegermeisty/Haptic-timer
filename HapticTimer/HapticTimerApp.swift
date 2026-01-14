//
//  HapticTimerApp.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 13/01/2026.
//

import SwiftUI
import SwiftData

@main
struct HapticTimerApp: App {
    @State private var purchaseState = PurchaseState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimerConfiguration.self,
            HapticPoint.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(purchaseState)
        }
        .modelContainer(sharedModelContainer)
    }
}
