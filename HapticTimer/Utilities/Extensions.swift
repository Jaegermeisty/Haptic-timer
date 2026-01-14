//
//  Extensions.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import Foundation
import CoreGraphics

extension Int {
    /// Format seconds as HH:MM:SS, MM:SS, or SS
    func formattedTime() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = self % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }

    /// Snap to 30-second intervals
    func snappedToInterval() -> Int {
        let intervals = self / Constants.Limits.snapInterval
        return intervals * Constants.Limits.snapInterval
    }
}

extension Double {
    /// Convert angle in degrees to radians
    var radians: Double {
        return self * .pi / 180
    }

    /// Convert radians to degrees
    var degrees: Double {
        return self * 180 / .pi
    }
}

extension CGFloat {
    /// Convert angle in degrees to radians
    var radians: CGFloat {
        return self * .pi / 180
    }

    /// Convert radians to degrees
    var degrees: CGFloat {
        return self * 180 / .pi
    }
}
