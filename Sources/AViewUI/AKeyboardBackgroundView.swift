import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct AKeyboardBackgroundView<KeyboardContent: View>: View {
    // 使用 @State 来存储屏幕宽度
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    // 使用 @Environment 获取当前的设备方向
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var makeContent: (CGFloat) -> KeyboardContent
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
        makeContent(screenWidth)
            .background(boardColor())
            .onChange(of: horizontalSizeClass) { _ in
                DispatchQueue.main.async {
                    // 当设备方向变化时更新屏幕宽度
                    self.screenWidth = UIScreen.main.bounds.width
                }
            }
    }

    public init(@ViewBuilder makeContent: @escaping (CGFloat) -> KeyboardContent) {
        self.makeContent = makeContent
    }
}
