import Foundation
import SwiftUI

#if !canImport(UIKit) || os(watchOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ACustomKeyboardInlineFieldHost<Keyboard: View>: View {
    let placeholder: String
    let externalText: String
    let setExternalTextFromInput: (String) -> Void
    let suppressNextFocusedUpdate: Bool
    let focused: Binding<Bool>?
    let configure: (ACustomKeyboardTextField) -> Void
    let keyboard: (ACustomKeyboardInputContext) -> Keyboard

    @State private var editingText: String
    @State private var selectedRange: NSRange
    @State private var didUpdateFromInput: Bool = false
    @State private var isFocused: Bool

    init(
        placeholder: String,
        externalText: String,
        setExternalTextFromInput: @escaping (String) -> Void,
        suppressNextFocusedUpdate: Bool,
        focused: Binding<Bool>?,
        configure: @escaping (ACustomKeyboardTextField) -> Void,
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard
    ) {
        self.placeholder = placeholder
        self.externalText = externalText
        self.setExternalTextFromInput = setExternalTextFromInput
        self.suppressNextFocusedUpdate = suppressNextFocusedUpdate
        self.focused = focused
        self.configure = configure
        self.keyboard = keyboard

        _editingText = State(initialValue: externalText)
        _selectedRange = State(initialValue: NSRange(location: externalText.count, length: 0))
        _isFocused = State(initialValue: focused?.wrappedValue ?? false)
    }

    private var textAlignment: TextAlignment {
        let config = ACustomKeyboardTextField()
        configure(config)
        return config.textAlignment.swiftUIAlignment
    }

    private func setFocused(_ value: Bool) {
        isFocused = value
        focused?.wrappedValue = value
        if !value {
            didUpdateFromInput = false
        }
    }

    private func syncFromExternal(_ newText: String) {
        if isFocused, suppressNextFocusedUpdate, didUpdateFromInput {
            didUpdateFromInput = false
            return
        }
        editingText = newText
        selectedRange = NSRange(location: newText.count, length: 0)
    }

    private func applyText(_ newText: String, selection: NSRange) {
        editingText = newText
        selectedRange = selection.clamped(to: newText.count)
        setExternalTextFromInput(newText)
        if suppressNextFocusedUpdate {
            didUpdateFromInput = true
        }
    }

    private func replaceSelection(_ input: String) {
        let clamped = selectedRange.clamped(to: editingText.count)
        let range = editingText.range(from: clamped)
        var newText = editingText
        newText.replaceSubrange(range, with: input)
        let newLocation = clamped.location + input.count
        applyText(newText, selection: NSRange(location: newLocation, length: 0))
    }

    private func deleteBackward() {
        let clamped = selectedRange.clamped(to: editingText.count)
        if clamped.length > 0 {
            let range = editingText.range(from: clamped)
            var newText = editingText
            newText.removeSubrange(range)
            applyText(newText, selection: NSRange(location: clamped.location, length: 0))
            return
        }
        guard clamped.location > 0 else { return }
        let lower = editingText.safeIndex(offset: clamped.location - 1)
        let upper = editingText.safeIndex(offset: clamped.location)
        var newText = editingText
        newText.removeSubrange(lower..<upper)
        applyText(newText, selection: NSRange(location: clamped.location - 1, length: 0))
    }

    private func moveCursor(_ offset: Int) {
        let base = selectedRange.clamped(to: editingText.count)
        let newLocation = max(0, min(editingText.count, base.location + offset))
        selectedRange = NSRange(location: newLocation, length: 0)
    }

    private func setSelection(_ range: NSRange) {
        selectedRange = range.clamped(to: editingText.count)
    }

    private func selectAll() {
        selectedRange = NSRange(location: 0, length: editingText.count)
    }

    private var context: ACustomKeyboardInputContext {
        ACustomKeyboardInputContext(
            text: editingText,
            selectedRange: selectedRange,
            isFocused: isFocused,
            insertText: { input in
                replaceSelection(input)
            },
            deleteBackward: {
                deleteBackward()
            },
            replaceSelection: { input in
                replaceSelection(input)
            },
            moveCursor: { offset in
                moveCursor(offset)
            },
            setSelection: { range in
                setSelection(range)
            },
            setText: { newText in
                applyText(newText, selection: NSRange(location: newText.count, length: 0))
            },
            clear: {
                applyText("", selection: NSRange(location: 0, length: 0))
            },
            selectAll: {
                selectAll()
            },
            dismissKeyboard: {
                setFocused(false)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                TextField(placeholder, text: $editingText)
                    .disabled(true)
                    .multilineTextAlignment(textAlignment)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                setFocused(true)
            }

            if isFocused {
                keyboard(context)
            }
        }
        .onAppear {
            syncFromExternal(externalText)
        }
        .onChange(of: externalText) { newValue in
            syncFromExternal(newValue)
        }
        .onChange(of: isFocused) { newValue in
            focused?.wrappedValue = newValue
        }
        .onChange(of: focused?.wrappedValue ?? false) { newValue in
            if newValue != isFocused {
                isFocused = newValue
            }
        }
    }
}

private extension String {
    func safeIndex(offset: Int) -> String.Index {
        let safeOffset = max(0, min(offset, count))
        return index(startIndex, offsetBy: safeOffset, limitedBy: endIndex) ?? endIndex
    }

    func range(from range: NSRange) -> Range<String.Index> {
        let lower = safeIndex(offset: range.location)
        let upper = safeIndex(offset: range.location + range.length)
        return min(lower, upper)..<max(lower, upper)
    }
}
#endif
