//
//  PatternSelectorSheet.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct PatternSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let point: HapticPointUI
    let onSelect: (HapticPattern) -> Void
    let onDelete: () -> Void
    let onPreview: (HapticPattern) -> Void

    @State private var selectedPattern: HapticPattern

    init(point: HapticPointUI, onSelect: @escaping (HapticPattern) -> Void, onDelete: @escaping () -> Void, onPreview: @escaping (HapticPattern) -> Void) {
        self.point = point
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.onPreview = onPreview
        self._selectedPattern = State(initialValue: point.pattern)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.secondaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Haptic Pattern")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("at \(point.triggerSeconds.formattedTime())")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Pattern list
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(HapticPattern.allCases, id: \.self) { pattern in
                                PatternRow(
                                    pattern: pattern,
                                    isSelected: selectedPattern == pattern,
                                    onTap: {
                                        selectedPattern = pattern
                                        onSelect(pattern)
                                    },
                                    onPreview: {
                                        onPreview(pattern)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Bottom buttons
                    VStack(spacing: 12) {
                        // Delete button (only for custom points)
                        if !point.isZeroPoint {
                            Button(action: {
                                onDelete()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Point")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Constants.Colors.tertiaryBackground)
                                .cornerRadius(12)
                            }
                        }

                        // Done button
                        Button(action: { dismiss() }) {
                            Text("Done")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Constants.Colors.defaultOrange)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PatternRow: View {
    let pattern: HapticPattern
    let isSelected: Bool
    let onTap: () -> Void
    let onPreview: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Constants.Colors.defaultOrange : .gray)

                // Pattern info
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(pattern.description)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }

                Spacer()

                // Preview button
                Button(action: onPreview) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Constants.Colors.defaultOrange)
                        .frame(width: 44, height: 44)
                        .background(Constants.Colors.tertiaryBackground)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(isSelected ? Constants.Colors.tertiaryBackground.opacity(0.5) : Constants.Colors.tertiaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let samplePoint = HapticPointUI(triggerSeconds: 300, pattern: .pulse)

    return PatternSelectorSheet(
        point: samplePoint,
        onSelect: { pattern in
            print("Selected: \(pattern.displayName)")
        },
        onDelete: {
            print("Delete tapped")
        },
        onPreview: { pattern in
            print("Preview: \(pattern.displayName)")
        }
    )
}
