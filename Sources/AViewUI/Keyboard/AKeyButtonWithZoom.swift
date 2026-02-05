import Foundation
import SwiftUI

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public struct AKeyButtonWithZoom<Content: View>: View {
    private var action: () -> Void
    private var content: () -> Content
    private var soundId: SystemSoundID
    private var colors: AKeyColors
    private var cornerRadius: CGFloat

    @Environment(\.colorScheme) private var colorTheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var isClicked = false

    private var borderColor: Color {
        switch colorTheme {
        case .light:
            return Color.black.opacity(isClicked ? 0.05 : 0.12)
        case .dark:
            return Color.white.opacity(isClicked ? 0.08 : 0.14)
        @unknown default:
            return Color.black.opacity(isClicked ? 0.05 : 0.12)
        }
    }

    private var shadowColor: Color {
        switch colorTheme {
        case .light:
            return Color.black.opacity(0.25)
        case .dark:
            return Color.black.opacity(0.55)
        @unknown default:
            return Color.black.opacity(0.25)
        }
    }

    private func makeGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isClicked else { return }
                isClicked = true
            }
            .onEnded { _ in
                isClicked = false
                playSystemSound(soundId)
                action()
            }
    }

    @ViewBuilder
    private func buttonContent() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colors.getColor(isClicked, colorTheme))
                .overlay(
                    Group {
                        if colors.showsBorderAndShadow {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(borderColor, lineWidth: 0.5)
                        }
                    }
                )
                .shadow(
                    color: colors.showsBorderAndShadow ? shadowColor : .clear,
                    radius: colors.showsBorderAndShadow ? (isClicked ? 0.4 : 1.2) : 0,
                    x: 0,
                    y: colors.showsBorderAndShadow ? (isClicked ? 0 : 1) : 0
                )
            content()  // 显示传入的内容视图
        }
        .gesture(makeGesture())
        .onChange(of: scenePhase) { _ in
            isClicked = false
        }
    }

    @ViewBuilder
    private func overlayContent() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colors.getColor(false, colorTheme))
                .overlay(
                    Group {
                        if colors.showsBorderAndShadow {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(borderColor, lineWidth: 0.5)
                        }
                    }
                )
                .shadow(
                    color: colors.showsBorderAndShadow ? shadowColor : .clear,
                    radius: colors.showsBorderAndShadow ? 6 : 0,
                    x: 0,
                    y: colors.showsBorderAndShadow ? 4 : 0
                )
            content()
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            buttonContent()
                .overlay {
                    if isClicked {
                        overlayContent()
                            .offset(y: -proxy.size.height)
                            .scaleEffect(1.6, anchor: .top)
                    }
                }
        }
    }

    public init(
        cornerRadius: CGFloat = 4, colors: AKeyColors? = nil, sound soundID: SystemSoundID = 1104,
        action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.colors = colors ?? .defaultColors
        self.action = action
        self.content = content
        self.soundId = soundID
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
#Preview {
    let base = AKeyboardBackgroundView { _ in
        KeyBoardSpaceAroundStack(columns: 10, rowSpace: 5, columnSpace: 3) {
            ForEach(1..<50) { index in
                AKeyButtonWithZoom(cornerRadius: 4, colors: .defaultColors) {
                    // print(index)
                } content: {
                    Text(index.description)
                }
            }
        }
    }
    .frame(height: 200)

    #if os(macOS)
    base
        .frame(width: 360)
        .padding()
    #elseif os(tvOS)
    base
        .frame(width: 600)
        .padding()
    #elseif os(visionOS)
    base
        .frame(width: 420)
        .padding()
    #elseif os(watchOS)
    AKeyboardBackgroundView { _ in
        KeyBoardSpaceAroundStack(columns: 6, rowSpace: 4, columnSpace: 2) {
            ForEach(1..<19) { index in
                AKeyButtonWithZoom(cornerRadius: 4, colors: .defaultColors) {
                    // print(index)
                } content: {
                    Text(index.description)
                }
            }
        }
    }
    #elseif os(iOS)
    base
    #else
    Text("Preview not available")
    #endif
}
