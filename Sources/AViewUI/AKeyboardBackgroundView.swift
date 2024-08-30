import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AKeyboardBackgroundView<KeyboardContent: View>: View {
    private var makeContent: () -> KeyboardContent
    @Environment(\.colorScheme) private var colorScheme

    private func boardColor() -> Color {
        switch colorScheme {
        case .light:
            return AKeyColors.keyboardLightBoardColor
        case .dark:
            return AKeyColors.keyboardDarkBoardColor
        @unknown default:
            return AKeyColors.keyboardLightBoardColor
        }
    }

    public var body: some View {
        makeContent()
            .background(boardColor())
    }

    public init(@ViewBuilder makeContent: @escaping () -> KeyboardContent) {
        self.makeContent = makeContent
    }
}
