//
//  PaywallView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct PaywallView: View {
    @Environment(PurchaseState.self) private var purchaseState
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Constants.Colors.defaultOrange)

                Text("Premium")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)

                Text("Unlock the full HapticTimer experience")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "dot.circle.and.hand.point.up.left.fill",
                    title: "5 custom haptic points",
                    subtitle: "(vs 3 in free)"
                )

                FeatureRow(
                    icon: "bookmark.fill",
                    title: "Save up to 15 timer configs",
                    subtitle: "Create presets for every need"
                )

                FeatureRow(
                    icon: "paintpalette.fill",
                    title: "10 beautiful circle colors",
                    subtitle: "Personalize your timer"
                )

                FeatureRow(
                    icon: "checkmark.seal.fill",
                    title: "One-time payment",
                    subtitle: "No subscription. Pay once, own it"
                )
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                Button(action: purchasePremium) {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(purchaseButtonText)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Constants.Colors.defaultOrange)
                .foregroundStyle(.white)
                .cornerRadius(12)
                .disabled(isPurchasing || isRestoring)

                Button(action: restorePurchase) {
                    if isRestoring {
                        ProgressView()
                            .tint(.gray)
                    } else {
                        Text("Restore Purchase")
                            .font(.system(size: 16))
                    }
                }
                .foregroundStyle(.gray)
                .disabled(isPurchasing || isRestoring)

                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var purchaseButtonText: String {
        if let product = purchaseState.premiumProduct {
            return "Upgrade for \(product.displayPrice)"
        } else {
            return "Upgrade for \(Constants.Purchase.premiumPrice)"
        }
    }

    private func purchasePremium() {
        isPurchasing = true
        errorMessage = nil

        Task {
            do {
                try await purchaseState.purchasePremium()
                isPurchasing = false
            } catch StoreError.userCancelled {
                isPurchasing = false
                // Don't show error for user cancellation
            } catch {
                isPurchasing = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func restorePurchase() {
        isRestoring = true
        errorMessage = nil

        Task {
            await purchaseState.restorePurchases()
            isRestoring = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Constants.Colors.defaultOrange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environment(PurchaseState())
        .background(Constants.Colors.background)
}
