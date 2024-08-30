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

    public static let defaultColors = AKeyButtonBGColors { isPressed, colorTheme in
        switch colorTheme {
        case .light:
            return isPressed ? keyboardLightKeyPressedColor : keyboardLightKeyColor
        case .dark:
            return isPressed ? keyboardDarkKeyPressedColor : keyboardDarkKeyColor
        @unknown default:
            return isPressed ? keyboardLightKeyPressedColor : keyboardLightKeyColor
        }
    }

    /// 苹果原生键盘背景板颜色 (亮色)
    public static let keyboardLightBoardColor = Color(.sRGB, red: 202 / 255.0, green: 205 / 255.0, blue: 212 / 255.0)
    /// 苹果原生键盘背景板颜色 (深色)
    public static let keyboardDarkBoardColor = Color(.sRGB, red: 38 / 255.0, green: 38 / 255.0, blue: 38 / 255.0)
    /// 苹果原生键盘亮色按键颜色
    public static let keyboardLightKeyColor = Color(.sRGB, red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
    /// 苹果原生键盘暗色按键颜色 (深色)
    public static let keyboardDarkKeyColor = Color(.sRGB, red: 96 / 255.0, green: 96 / 255.0, blue: 96 / 255.0)
    /// 苹果原生键盘亮色按键颜色 (按下)
    public static let keyboardLightKeyPressedColor = Color(.sRGB, red: 175 / 255.0, green: 186 / 255.0, blue: 202 / 255.0)
    /// 苹果原生键盘亮色按键颜色 (深色 + 按下)
    public static let keyboardDarkKeyPressedColor = Color(.sRGB, red: 62 / 255.0, green: 62 / 255.0, blue: 62 / 255.0)
}
