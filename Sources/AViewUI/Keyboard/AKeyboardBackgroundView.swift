import SwiftUI

#if os(iOS)

@available(iOS 13.0, *)
private class AOrientationObserver: ObservableObject {
    @Published var screenWidth: CGFloat = UIScreen.main.bounds.width

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func orientationDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.screenWidth = UIScreen.main.bounds.width
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

@available(iOS 14.0, *)
public struct AKeyboardBackgroundView<KeyboardContent: View>: View {
    @StateObject private var orientation: AOrientationObserver = .init()

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
        makeContent(orientation.screenWidth)
            .background(boardColor())
    }

    public init(@ViewBuilder makeContent: @escaping (CGFloat) -> KeyboardContent) {
        self.makeContent = makeContent
    }
}

#endif
