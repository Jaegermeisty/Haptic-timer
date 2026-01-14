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
    let onDrag: (Int) -> Void

    @State private var isDragging = false
    @State private var draggedSeconds: Int?

    private var displaySeconds: Int {
        draggedSeconds ?? point.triggerSeconds
    }

    private var angle: Double {
        // Calculate angle based on trigger time
        // 0 seconds = top (0°), drains clockwise
        let progress = Double(displaySeconds) / Double(totalDuration)
        return progress * 360.0 - 90.0 // -90 to start at top
    }

    private var position: CGPoint {
        let radius = circleSize / 2
        let angleInRadians = angle.radians
        let x = radius + cos(angleInRadians) * radius
        let y = radius + sin(angleInRadians) * radius
        return CGPoint(x: x, y: y)
    }

    private func angleFromDragLocation(_ location: CGPoint) -> Double {
        let center = CGPoint(x: circleSize / 2, y: circleSize / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let angleRadians = atan2(dy, dx)
        var angleDegrees = angleRadians.degrees

        // Normalize to 0-360 range
        if angleDegrees < 0 {
            angleDegrees += 360
        }

        // Adjust for starting at top (-90°)
        angleDegrees = (angleDegrees + 90).truncatingRemainder(dividingBy: 360)

        return angleDegrees
    }

    private func secondsFromAngle(_ angle: Double) -> Int {
        let progress = angle / 360.0
        let seconds = Int(progress * Double(totalDuration))
        return seconds.snappedToInterval()
    }

    var body: some View {
        ZStack {
            // The point itself
            Circle()
                .fill(point.isZeroPoint ? Constants.Colors.defaultOrange : .white)
                .frame(
                    width: isDragging ? Constants.UI.hapticPointSizeDragging : (point.isZeroPoint ? Constants.UI.zeroPointSize : Constants.UI.hapticPointSize),
                    height: isDragging ? Constants.UI.hapticPointSizeDragging : (point.isZeroPoint ? Constants.UI.zeroPointSize : Constants.UI.hapticPointSize)
                )
                .position(position)
                .opacity(isDragging ? 0.8 : 1.0)

            // Time label while dragging
            if isDragging, let seconds = draggedSeconds {
                Text(seconds.formattedTime())
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(6)
                    .position(
                        x: position.x,
                        y: position.y - 25 // Offset above the point
                    )
            }
        }
        .gesture(
            point.isZeroPoint ? nil : DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                    }
                    let angle = angleFromDragLocation(value.location)
                    let newSeconds = secondsFromAngle(angle)
                    draggedSeconds = newSeconds
                }
                .onEnded { _ in
                    if let seconds = draggedSeconds {
                        onDrag(seconds)
                    }
                    isDragging = false
                    draggedSeconds = nil
                }
        )
        .onTapGesture {
            if !isDragging && !point.isZeroPoint {
                onTap()
            }
        }
    }
}
