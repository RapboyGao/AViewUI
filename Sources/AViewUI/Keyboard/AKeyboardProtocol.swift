import SwiftUI

#if os(iOS)

/// 通用键盘协议：提供常用按键构建函数与基础样式。
@available(iOS 15, *)
public protocol AKeyboardProtocol {
    var input: ACustomKeyboardInputContext { get }
    var lettersFont: Font { get }
    var numbersFont: Font { get }
    var keyCornerRadius: CGFloat { get }
    var doneButtonTitle: String { get }
}

@available(iOS 15, *)
public extension AKeyboardProtocol {
    var lettersFont: Font { .system(size: 10) }
    var numbersFont: Font { .system(size: 23) }
    var keyCornerRadius: CGFloat { 4 }
    var doneButtonTitle: String { "Done" }
}

@available(iOS 16, *)
public extension AKeyboardProtocol where Self: View {
    @ViewBuilder
    func makeTextButton(_ text: String) -> some View {
        AKeyButton(keyCornerRadius) {
            input.insertText(text)
        } content: { _ in
            Text(text)
                .font(numbersFont)
        }
    }

    @ViewBuilder
    func makeTextButton2(_ text: String) -> some View {
        AKeyButton(keyCornerRadius, colors: .functionKeyColors) {
            input.insertText(text)
        } content: { _ in
            Text(text)
                .font(numbersFont)
        }
    }

    @ViewBuilder
    func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(keyCornerRadius) {
            input.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
        }
    }

    @ViewBuilder
    func makeDeleteButton(beforeDelete: @escaping () -> Void = {}) -> some View {
        AKeyButton(keyCornerRadius, colors: .functionKeyColors, sound: 1155) {
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
        AKeyButton(keyCornerRadius, sound: 1155) {
            beforeDelete()
            input.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
    }

    @ViewBuilder
    func equalButton(beforeEqual: @escaping () -> Void) -> some View {
        AKeyButton(cornerRadius: keyCornerRadius) { isClicked, colorScheme in
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
    func doneButton(beforeDone: @escaping () -> Void) -> some View {
        AKeyButton(cornerRadius: keyCornerRadius) { isClicked, colorScheme in
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
        AKeyButton(keyCornerRadius, colors: .functionKeyColors, sound: 1155) {
            beforeClear()
            input.clear()
        } content: { _ in
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 24))
        }
    }

    @ViewBuilder
    func clearButton2(beforeClear: @escaping () -> Void = {}) -> some View {
        AKeyButton(keyCornerRadius, sound: 1155) {
            beforeClear()
            input.clear()
        } content: { _ in
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 24))
        }
    }
}

#endif
