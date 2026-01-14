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

    private var circleSize: CGFloat {
        // TODO: Adjust based on device size
        Constants.UI.circleSizeStandard
    }

    var body: some View {
        ZStack {
            // Time display at top
            Text(remainingTime.formattedTime())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .offset(y: -circleSize / 2 - 20)

            // Background track (full circle minus top arc)
            Circle()
                .trim(from: 0, to: 0.89) // Leave ~40° at top for "cut"
                .stroke(
                    Constants.Colors.trackColor,
                    style: StrokeStyle(
                        lineWidth: Constants.UI.circleStrokeWidth,
                        lineCap: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(90)) // Start at top

            // Progress fill
            Circle()
                .trim(from: 0, to: min(progress * 0.89, 0.89)) // Match the track trim
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: Constants.UI.circleStrokeWidth,
                        lineCap: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(90)) // Start at top
                .animation(.linear(duration: 0.1), value: progress)
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
                color: Constants.Colors.defaultOrange
            )

            CircleProgressView(
                progress: 0.5,
                remainingTime: 300,
                color: Constants.Colors.defaultOrange
            )

            CircleProgressView(
                progress: 0.1,
                remainingTime: 60,
                color: Constants.Colors.defaultOrange
            )
        }
    }
}
