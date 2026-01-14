//
//  PurchaseState.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import Observation
import StoreKit

@Observable
class PurchaseState {
    private let storeManager = StoreManager.shared

    var isPremium: Bool {
        storeManager.isPremium
    }

    var products: [Product] {
        storeManager.products
    }

    var premiumProduct: Product? {
        storeManager.products.first { $0.id == Constants.Purchase.premiumProductID }
    }

    init() {
        // Load products and check purchases on initialization
        Task {
            await storeManager.loadProducts()
            await storeManager.checkPurchasedProducts()
        }
    }

    // MARK: - Purchase Actions

    func purchasePremium() async throws {
        guard let product = premiumProduct else {
            throw StoreError.unknown
        }

        try await storeManager.purchase(product)
    }

    func restorePurchases() async {
        await storeManager.restorePurchases()
    }
}
