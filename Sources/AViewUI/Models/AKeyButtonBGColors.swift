import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AKeyButtonBGColors: Sendable {
    public var getColor: @Sendable (Bool, ColorScheme) -> Color

    public init(normal: Color, onClick: Color, normalDark: Color, onClickDark: Color) {
        self.getColor = { isClicked, colorScheme in
            if isClicked {
                switch colorScheme {
                case .light:
                    return onClick
                case .dark:
                    return onClickDark
                @unknown default:
                    return onClick
                }
            } else {
                switch colorScheme {
                case .light:
                    return normal
                case .dark:
                    return normalDark
                @unknown default:
                    return normal
                }
            }
        }
    }

    public init(getColor: @Sendable @escaping (Bool, ColorScheme) -> Color) {
        self.getColor = getColor
    }

    public static let defaultColors = AKeyButtonBGColors { isClicked, colorTheme in
        let whiteFactor = isClicked ? 0.85 : 0.93
        let darkFactor = isClicked ? 0.3 : 0.15
        return Color(white: colorTheme == .dark ? darkFactor : whiteFactor)
    }

    public static let defaultColors2 = AKeyButtonBGColors { isClicked, colorTheme in
        let whiteFactor = isClicked ? 0.9 : 1
        let darkFactor = isClicked ? 0.7 : 0.5
        return Color(white: colorTheme == .dark ? darkFactor : whiteFactor)
    }
}
