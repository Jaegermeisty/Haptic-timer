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
    let totalDuration: Int // total seconds for positioning points
    let color: Color
    let isTimerRunning: Bool
    let hapticPoints: [HapticPointUI]
    let onTimeTap: () -> Void
    let onPointTap: (HapticPointUI) -> Void
    let onPointDrag: (HapticPointUI, Int) -> Void

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

            // Haptic points on circle
            if totalDuration > 0 {
                ForEach(hapticPoints) { point in
                    HapticPointView(
                        point: point,
                        circleSize: circleSize,
                        totalDuration: totalDuration,
                        onTap: {
                            onPointTap(point)
                        },
                        onDrag: { newSeconds in
                            onPointDrag(point, newSeconds)
                        }
                    )
                }
            }

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
    let samplePoints = [
        HapticPointUI(triggerSeconds: 0, isZeroPoint: true),
        HapticPointUI(triggerSeconds: 300),
        HapticPointUI(triggerSeconds: 120)
    ]

    return ZStack {
        Constants.Colors.background
            .ignoresSafeArea()

        VStack(spacing: 40) {
            CircleProgressView(
                progress: 1.0,
                remainingTime: 600,
                totalDuration: 600,
                color: Constants.Colors.defaultOrange,
                isTimerRunning: false,
                hapticPoints: samplePoints,
                onTimeTap: {},
                onPointTap: { _ in },
                onPointDrag: { _, _ in }
            )

            CircleProgressView(
                progress: 0.5,
                remainingTime: 300,
                totalDuration: 600,
                color: Constants.Colors.defaultOrange,
                isTimerRunning: true,
                hapticPoints: samplePoints,
                onTimeTap: {},
                onPointTap: { _ in },
                onPointDrag: { _, _ in }
            )
        }
    }
}
