//
//  HapticPointView.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI
import UIKit

struct HapticPointView: View {
    let point: HapticPointUI
    let circleSize: CGFloat
    let totalDuration: Int
    let onTap: () -> Void
    let onDrag: (Int) -> Void

    @State private var isDragging = false
    @State private var dragAngle: Double?

    private var displayAngle: Double {
        if let dragAngle = dragAngle {
            return dragAngle
        }
        // Calculate angle based on trigger time
        // 0 seconds = top (0°), drains clockwise
        let progress = Double(point.triggerSeconds) / Double(totalDuration)
        return progress * 360.0
    }

    private var position: CGPoint {
        let radius = circleSize / 2
        // Convert angle to radians, accounting for starting at top (-90°)
        let angleInRadians = (displayAngle - 90.0).radians
        let x = circleSize / 2 + cos(angleInRadians) * radius
        let y = circleSize / 2 + sin(angleInRadians) * radius
        return CGPoint(x: x, y: y)
    }

    private var displaySeconds: Int {
        let progress = displayAngle / 360.0
        let seconds = Int(progress * Double(totalDuration))
        return seconds.snappedToInterval()
    }

    private func angleFromDragLocation(_ location: CGPoint) -> Double {
        let center = CGPoint(x: circleSize / 2, y: circleSize / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let angleRadians = atan2(dy, dx)
        var angleDegrees = Double(angleRadians.degrees)

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
        var seconds = Int(progress * Double(totalDuration))

        // Clamp to valid range
        seconds = max(0, min(seconds, totalDuration))

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
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: position)

            // Time label while dragging
            if isDragging {
                Text(displaySeconds.formattedTime())
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(6)
                    .position(
                        x: position.x,
                        y: max(20, position.y - 30) // Offset above the point, but keep in bounds
                    )
            }
        }
        .frame(width: circleSize, height: circleSize)
        .contentShape(Rectangle())
        .simultaneousGesture(
            // Tap gesture for opening pattern selector
            TapGesture()
                .onEnded { _ in
                    if !point.isZeroPoint && !isDragging {
                        onTap()
                    }
                }
        )
        .simultaneousGesture(
            // Long press + drag for moving the point
            point.isZeroPoint ? nil : LongPressGesture(minimumDuration: 0.3)
                .sequenced(before: DragGesture())
                .onChanged { value in
                    switch value {
                    case .second(true, let drag):
                        if let drag = drag {
                            if !isDragging {
                                // Haptic feedback when drag starts
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                            isDragging = true
                            let angle = angleFromDragLocation(drag.location)
                            dragAngle = angle
                        }
                    default:
                        break
                    }
                }
                .onEnded { value in
                    if isDragging, let angle = dragAngle {
                        let newSeconds = secondsFromAngle(angle)
                        onDrag(newSeconds)
                        // Haptic feedback when point snaps to position
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    isDragging = false
                    dragAngle = nil
                }
        )
    }
}
