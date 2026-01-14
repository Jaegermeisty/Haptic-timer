//
//  TimePickerSheet.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.secondaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Set Duration")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.top)

                    HStack(spacing: 12) {
                        // Hours
                        VStack(spacing: 8) {
                            Text("Hours")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Picker("Hours", selection: $hours) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)")
                                        .tag(hour)
                                        .foregroundStyle(.white)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }

                        // Minutes
                        VStack(spacing: 8) {
                            Text("Minutes")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Picker("Minutes", selection: $minutes) {
                                ForEach(0..<60) { minute in
                                    Text(String(format: "%02d", minute))
                                        .tag(minute)
                                        .foregroundStyle(.white)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }

                        // Seconds
                        VStack(spacing: 8) {
                            Text("Seconds")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Picker("Seconds", selection: $seconds) {
                                ForEach(0..<60) { second in
                                    Text(String(format: "%02d", second))
                                        .tag(second)
                                        .foregroundStyle(.white)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }
                    }

                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Constants.Colors.defaultOrange)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    TimePickerSheet(
        hours: .constant(0),
        minutes: .constant(10),
        seconds: .constant(0)
    )
}
