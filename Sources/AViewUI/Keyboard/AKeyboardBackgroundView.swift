import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AKeyboardBackgroundView<KeyboardContent: View>: View {
    private var makeContent: (CGFloat) -> KeyboardContent

    @Environment(\.colorScheme) private var colorScheme

    private func boardColor() -> some ShapeStyle {
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
        GeometryReader { proxy in
            makeContent(proxy.size.width)
                .background {
                    Rectangle()
                        .overlay(boardColor())
                        .background {
                            #if os(watchOS)
                            if #available(watchOS 10.0, *) {
                                Rectangle().fill(.ultraThinMaterial)
                            } else {
                                Rectangle().fill(Color.clear)
                            }
                            #else
                            Rectangle().fill(.ultraThinMaterial)
                            #endif
                        }
                }
                .padding(.top, 6)
        }
    }

    public init(@ViewBuilder makeContent: @escaping (CGFloat) -> KeyboardContent) {
        self.makeContent = makeContent
    }
}
