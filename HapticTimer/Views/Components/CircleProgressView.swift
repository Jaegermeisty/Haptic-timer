//
//  CircleProgressView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct CircleProgressView: View {
    let progress: Double // 0.0 to 1.0
    let remainingTime: Int // in seconds
    let color: Color
    let isTimerRunning: Bool
    let onTimeTap: () -> Void

    private var circleSize: CGFloat {
        // TODO: Adjust based on device size
        Constants.UI.circleSizeStandard
    }

    var body: some View {
        ZStack {
            // Background track (full circle)
            Circle()
                .stroke(
                    Constants.Colors.trackColor,
                    style: StrokeStyle(
                        lineWidth: Constants.UI.circleStrokeWidth,
                        lineCap: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)

            // Progress fill (drains clockwise from top)
            Circle()
                .trim(from: 1 - progress, to: 1)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: Constants.UI.circleStrokeWidth,
                        lineCap: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90)) // Start at top
                .animation(.linear, value: progress)

            // Time display in center (tappable when stopped)
            Button(action: onTimeTap) {
                VStack(spacing: 4) {
                    Text(remainingTime.formattedTime())
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !isTimerRunning {
                        Text("tap to edit")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isTimerRunning)
        }
    }
}

#Preview {
    ZStack {
        Constants.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 40) {
            CircleProgressView(
                progress: 1.0,
                remainingTime: 600,
                color: Constants.Colors.defaultOrange,
                isTimerRunning: false,
                onTimeTap: {}
            )

            CircleProgressView(
                progress: 0.5,
                remainingTime: 300,
                color: Constants.Colors.defaultOrange,
                isTimerRunning: true,
                onTimeTap: {}
            )

            CircleProgressView(
                progress: 0.1,
                remainingTime: 60,
                color: Constants.Colors.defaultOrange,
                isTimerRunning: true,
                onTimeTap: {}
            )
        }
    }
}
