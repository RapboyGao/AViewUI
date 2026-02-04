import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AKeyColors: Sendable {
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

    public static let defaultColors = AKeyColors { isPressed, colorTheme in
        switch colorTheme {
        case .light:
            return isPressed ? keyboardLightKeyPressedColor : keyboardLightKeyColor
        case .dark:
            return isPressed ? keyboardDarkKeyPressedColor : keyboardDarkKeyColor
        @unknown default:
            return isPressed ? keyboardLightKeyPressedColor : keyboardLightKeyColor
        }
    }

    public static let sameAsBackground = AKeyColors { _, colorTheme in
        switch colorTheme {
        case .light:
            return keyboardLightBoardColor
        case .dark:
            return keyboardDarkBoardColor
        @unknown default:
            return keyboardLightBoardColor
        }
    }

    public static let functionKeyColors = AKeyColors { isPressed, colorTheme in
        switch colorTheme {
        case .light:
            return isPressed ? keyboardLightFunctionKeyPressedColor : keyboardLightFunctionKeyColor
        case .dark:
            return isPressed ? keyboardDarkFunctionKeyPressedColor : keyboardDarkFunctionKeyColor
        @unknown default:
            return isPressed ? keyboardLightFunctionKeyPressedColor : keyboardLightFunctionKeyColor
        }
    }

    /// 苹果原生键盘背景板颜色 (亮色)
    public static let keyboardLightBoardColor = Color(.sRGB, red: 236 / 255.0, green: 238 / 255.0, blue: 241 / 255.0).opacity(0.88)
    /// 苹果原生键盘背景板颜色 (深色)
    public static let keyboardDarkBoardColor = Color(.sRGB, red: 33 / 255.0, green: 33 / 255.0, blue: 35 / 255.0).opacity(0.8)
    /// 苹果原生键盘亮色按键颜色
    public static let keyboardLightKeyColor = Color(.sRGB, red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0).opacity(0.97)
    /// 苹果原生键盘暗色按键颜色 (深色)
    public static let keyboardDarkKeyColor = Color(.sRGB, red: 68 / 255.0, green: 68 / 255.0, blue: 72 / 255.0).opacity(0.9)
    /// 苹果原生键盘亮色按键颜色 (按下)
    public static let keyboardLightKeyPressedColor = Color(
        .sRGB, red: 200 / 255.0, green: 204 / 255.0, blue: 212 / 255.0).opacity(0.95)
    /// 苹果原生键盘亮色按键颜色 (深色 + 按下)
    public static let keyboardDarkKeyPressedColor = Color(.sRGB, red: 55 / 255.0, green: 55 / 255.0, blue: 58 / 255.0).opacity(0.9)

    /// 苹果原生键盘功能键颜色 (亮色)
    public static let keyboardLightFunctionKeyColor = Color(.sRGB, red: 209 / 255.0, green: 213 / 255.0, blue: 219 / 255.0).opacity(0.95)
    /// 苹果原生键盘功能键颜色 (深色)
    public static let keyboardDarkFunctionKeyColor = Color(.sRGB, red: 82 / 255.0, green: 82 / 255.0, blue: 86 / 255.0).opacity(0.9)
    /// 苹果原生键盘功能键颜色 (亮色 + 按下)
    public static let keyboardLightFunctionKeyPressedColor = Color(.sRGB, red: 191 / 255.0, green: 195 / 255.0, blue: 202 / 255.0).opacity(0.95)
    /// 苹果原生键盘功能键颜色 (深色 + 按下)
    public static let keyboardDarkFunctionKeyPressedColor = Color(.sRGB, red: 66 / 255.0, green: 66 / 255.0, blue: 70 / 255.0).opacity(0.9)
}
