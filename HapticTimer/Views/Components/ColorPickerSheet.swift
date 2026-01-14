//
//  ColorPickerSheet.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct ColorPickerSheet: View {
    let currentColorHex: String
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseState.self) private var purchaseState

    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Constants.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Choose Color")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Color grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Constants.Colors.premiumColors, id: \.hex) { colorOption in
                            ColorOptionButton(
                                name: colorOption.name,
                                hex: colorOption.hex,
                                isSelected: colorOption.hex == currentColorHex,
                                onTap: {
                                    selectColor(colorOption.hex)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                if !purchaseState.isPremium {
                    Text("Premium feature")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .padding(.bottom)
                }
            }
        }
    }

    private func selectColor(_ hex: String) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        onSelect(hex)
        dismiss()
    }
}

struct ColorOptionButton: View {
    let name: String
    let hex: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 60, height: 60)

                    if isSelected {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 60, height: 60)

                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .gray)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ColorPickerSheet(
        currentColorHex: "FF8C42",
        onSelect: { _ in }
    )
    .environment(PurchaseState())
}
