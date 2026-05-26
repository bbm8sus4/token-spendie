import SwiftUI

/// A preset color theme. Maps the three usage tiers to colors.
enum Theme: String, CaseIterable, Identifiable {
    case `default`
    case ocean
    case sunset
    case violet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default: return "Default"
        case .ocean:   return "Ocean"
        case .sunset:  return "Sunset"
        case .violet:  return "Violet"
        }
    }

    /// Tier colors: (calm `< 70%`, warn `70–90%`, hot `> 90%`).
    private var tierColors: (calm: Color, warn: Color, hot: Color) {
        switch self {
        case .default:
            return (Color(red: 0.851, green: 0.467, blue: 0.341),
                    Color(red: 0.906, green: 0.306, blue: 0.225),
                    Color(red: 0.800, green: 0.180, blue: 0.180))
        case .ocean:
            return (Color(red: 0.208, green: 0.753, blue: 0.651),
                    Color(red: 0.941, green: 0.741, blue: 0.353),
                    Color(red: 0.937, green: 0.435, blue: 0.424))
        case .sunset:
            return (Color(red: 0.941, green: 0.651, blue: 0.369),
                    Color(red: 0.925, green: 0.478, blue: 0.333),
                    Color(red: 0.851, green: 0.294, blue: 0.431))
        case .violet:
            return (Color(red: 0.435, green: 0.561, blue: 0.839),
                    Color(red: 0.663, green: 0.455, blue: 0.847),
                    Color(red: 0.851, green: 0.373, blue: 0.604))
        }
    }

    /// The color for a usage tier under this theme.
    func color(for level: UsageLevel) -> Color {
        switch level {
        case .calm: return tierColors.calm
        case .warn: return tierColors.warn
        case .hot:  return tierColors.hot
        }
    }
}
