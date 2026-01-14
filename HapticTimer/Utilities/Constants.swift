//
//  Constants.swift
//  HapticTimer
//
//  Created by Mathias Jæger-Pedersen on 14/01/2026.
//

import SwiftUI

enum Constants {
    // Feature Limits
    enum Limits {
        static let freeHapticPoints = 3
        static let premiumHapticPoints = 5
        static let premiumConfigSlots = 15
        static let minimumPointSpacing = 30 // seconds
        static let snapInterval = 30 // seconds
    }

    // Timer Constraints
    enum Timer {
        static let minimumDuration = 30 // seconds
        static let maximumDuration = 86399 // 23:59:59
    }

    // UI Dimensions
    enum UI {
        static let circleStrokeWidth: CGFloat = 20
        static let circleSizeCompact: CGFloat = 260
        static let circleSizeStandard: CGFloat = 280
        static let circleSizeLarge: CGFloat = 320

        static let hapticPointSize: CGFloat = 8
        static let hapticPointSizeDragging: CGFloat = 10
        static let zeroPointSize: CGFloat = 10
    }

    // Colors
    enum Colors {
        static let background = Color(hex: "1C1C1E")
        static let secondaryBackground = Color(hex: "2C2C2E")
        static let tertiaryBackground = Color(hex: "3A3A3C")

        static let trackColor = Color(hex: "2C2C2E")
        static let defaultOrange = Color(hex: "FF8C42")
        static let defaultOrangeHex = "FF8C42"
    }

    // Purchase
    enum Purchase {
        static let premiumProductID = "com.mathias.haptictimer.premium"
        static let premiumPrice = "$4.99"
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "000000" }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
