//
//  PaywallView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct PaywallView: View {
    @Environment(PurchaseState.self) private var purchaseState

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
                    Text("Upgrade for \(Constants.Purchase.premiumPrice)")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.defaultOrange)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }

                Button(action: restorePurchase) {
                    Text("Restore Purchase")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func purchasePremium() {
        // TODO: Implement StoreKit 2 purchase
        // For now, just toggle for testing
        purchaseState.isPremium = true
    }

    private func restorePurchase() {
        // TODO: Implement restore purchase
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
