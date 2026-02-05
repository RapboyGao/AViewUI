import SwiftUI

/// 通用键盘协议：提供常用按键构建函数与基础样式。
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public protocol AKeyboardProtocol {
    var input: ACustomKeyboardInputContext { get }
    var lettersFont: Font { get }
    var numbersFont: Font { get }
    var connerRadius: CGFloat { get }
    var doneButtonTitle: String { get }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public extension AKeyboardProtocol {
    var lettersFont: Font { .system(size: 10) }
    var numbersFont: Font { .system(size: 23) }
    var connerRadius: CGFloat { 4 }
    var doneButtonTitle: String { I18n.done }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public extension AKeyboardProtocol where Self: View {
    @ViewBuilder
    func makeTextButton(_ text: String) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(text)
        } content: { isClicked in
            Text(text)
                .font(numbersFont)
                .bold(isClicked)
        }
    }

    @ViewBuilder
    func makeTextButton2(_ text: String) -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground) {
            input.insertText(text)
        } content: { isClicked in
            Text(text)
                .font(numbersFont)
                .bold(isClicked)
        }
    }

    @ViewBuilder
    func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(number.formatted(.number))
        } content: { isClicked in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
                .bold(isClicked)
        }
    }

    @ViewBuilder
    func makeDeleteButton(beforeDelete: @escaping () -> Void = {}) -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground, sound: 1155) {
            beforeDelete()
            input.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
    }

    @ViewBuilder
    func makeDeleteButton2(beforeDelete: @escaping () -> Void = {}) -> some View {
        AKeyButton(connerRadius, sound: 1155) {
            beforeDelete()
            input.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
    }

    @ViewBuilder
    func equalButton(beforeEqual: @escaping () -> Void = {}) -> some View {
        AKeyButton(cornerRadius: connerRadius) { isClicked, colorScheme in
            if isClicked {
                return AKeyColors.defaultColors.getColor(isClicked, colorScheme)
            } else {
                return .blue
            }
        } action: {
            beforeEqual()
            input.dismissKeyboard()
        } content: { isClicked in
            Text("=")
                .font(numbersFont)
                .foregroundColor(isClicked ? .primary : .white)
        }
    }

    @ViewBuilder
    func doneButton(beforeDone: @escaping () -> Void = {}) -> some View {
        AKeyButton(cornerRadius: connerRadius) { isClicked, colorScheme in
            if isClicked {
                return AKeyColors.defaultColors.getColor(isClicked, colorScheme)
            } else {
                return .blue
            }
        } action: {
            beforeDone()
            input.dismissKeyboard()
        } content: { isClicked in
            Text(doneButtonTitle)
                .font(numbersFont)
                .foregroundColor(isClicked ? .primary : .white)
        }
    }

    @ViewBuilder
    func clearButton(beforeClear: @escaping () -> Void = {}) -> some View {
        ClearRotateButton(
            input: input,
            connerRadius: connerRadius,
            colors: .sameAsBackground,
            sound: 1155,
            beforeClear: beforeClear
        )
    }

    @ViewBuilder
    func clearButton2(beforeClear: @escaping () -> Void = {}) -> some View {
        ClearRotateButton(
            input: input,
            connerRadius: connerRadius,
            colors: .defaultColors,
            sound: 1155,
            beforeClear: beforeClear
        )
    }

    @ViewBuilder
    func imageButton(systemName: String, action: @escaping () -> Void = {}) -> some View {
        AKeyButton(cornerRadius: connerRadius, colors: .defaultColors, sound: 1155, action: action) {
            Image(systemName: systemName)
        }
    }
    
    @ViewBuilder
    func imageButton2(systemName: String, action: @escaping () -> Void = {}) -> some View {
        AKeyButton(cornerRadius: connerRadius, colors: .sameAsBackground, sound: 1155, action: action) {
            Image(systemName: systemName)
        }
    }

}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
fileprivate struct ClearRotateButton: View {
    private let input: ACustomKeyboardInputContext
    @State private var turnDirection: Angle = .zero
    private let connerRadius: CGFloat
    private let colors: AKeyColors
    private let sound: SystemSoundID
    private let beforeClear: () -> Void

    public init(
        input: ACustomKeyboardInputContext,
        connerRadius: CGFloat = 4,
        colors: AKeyColors = .functionKeyColors,
        sound: SystemSoundID = 1155,
        beforeClear: @escaping () -> Void = {}
    ) {
        self.input = input
        self.connerRadius = connerRadius
        self.colors = colors
        self.sound = sound
        self.beforeClear = beforeClear
    }

    public var body: some View {
        AKeyButton(connerRadius, colors: colors, sound: sound) {
            beforeClear()
            input.clear()
            withAnimation {
                turnDirection -= .degrees(360)
            }
        } content: { _ in
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 24))
                .rotationEffect(turnDirection)
        }
    }
}
