//
//  PurchaseState.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import Observation

@Observable
class PurchaseState {
    var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }

    init() {
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
}
