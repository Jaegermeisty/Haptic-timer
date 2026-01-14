//
//  HapticPointView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

struct HapticPointView: View {
    let point: HapticPointUI
    let circleSize: CGFloat
    let totalDuration: Int
    let onTap: () -> Void

    private var angle: Double {
        // Calculate angle based on trigger time
        // 0 seconds = top (0°), drains clockwise
        let progress = Double(point.triggerSeconds) / Double(totalDuration)
        return progress * 360.0 - 90.0 // -90 to start at top
    }

    private var position: CGPoint {
        let radius = circleSize / 2
        let angleInRadians = angle.radians
        let x = radius + cos(angleInRadians) * radius
        let y = radius + sin(angleInRadians) * radius
        return CGPoint(x: x, y: y)
    }

    var body: some View {
        Circle()
            .fill(point.isZeroPoint ? Constants.Colors.defaultOrange : .white)
            .frame(
                width: point.isZeroPoint ? Constants.UI.zeroPointSize : Constants.UI.hapticPointSize,
                height: point.isZeroPoint ? Constants.UI.zeroPointSize : Constants.UI.hapticPointSize
            )
            .position(position)
            .onTapGesture {
                onTap()
            }
    }
}
