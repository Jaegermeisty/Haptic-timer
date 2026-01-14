//
//  StoreManager.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import StoreKit
import Observation

@Observable
class StoreManager {
    static let shared = StoreManager()

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactionUpdates()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        do {
            let productIDs = [Constants.Purchase.premiumProductID]
            products = try await Product.products(for: productIDs)
            print("✅ Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase State

    func checkPurchasedProducts() async {
        purchasedProductIDs.removeAll()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Add to purchased set if valid
                purchasedProductIDs.insert(transaction.productID)
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }
    }

    var isPremium: Bool {
        purchasedProductIDs.contains(Constants.Purchase.premiumProductID)
    }

    // MARK: - Purchase Flow

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Add to purchased products
            purchasedProductIDs.insert(transaction.productID)

            // Finish the transaction
            await transaction.finish()

            print("✅ Purchase successful: \(transaction.productID)")

        case .userCancelled:
            print("⚠️ User cancelled purchase")
            throw StoreError.userCancelled

        case .pending:
            print("⏳ Purchase pending")
            throw StoreError.pending

        @unknown default:
            print("❌ Unknown purchase result")
            throw StoreError.unknown
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchasedProducts()
            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Transaction Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverified
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Transaction Updates Listener

    private func listenForTransactionUpdates() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)

                    // Update purchased products
                    if let productID = transaction?.productID {
                        await MainActor.run {
                            self?.purchasedProductIDs.insert(productID)
                        }
                    }

                    // Finish transaction
                    await transaction?.finish()
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error, LocalizedError {
    case userCancelled
    case pending
    case unverified
    case unknown

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unverified:
            return "Transaction could not be verified"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
