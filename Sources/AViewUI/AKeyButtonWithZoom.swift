import AVFoundation
import Foundation
import SwiftUI

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public struct AKeyButtonWithZoom<Content: View>: View {
    private var action: () -> Void
    private var content: () -> Content
    private var soundId: SystemSoundID = 1104
    private var colors: AKeyColors
    private var cornerRadius: CGFloat

    @Environment(\.colorScheme) private var colorTheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var isClicked = false

    private func makeGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isClicked else { return }
                isClicked = true
            }
            .onEnded { _ in
                isClicked = false
                AudioServicesPlaySystemSound(soundId)
                action()
            }
    }

    @ViewBuilder
    private func buttonContent() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colors.getColor(isClicked, colorTheme))
            content() // 显示传入的内容视图
        }
        .gesture(makeGesture())
        .animation(.easeInOut(duration: 0.1), value: isClicked)
        .onChange(of: scenePhase) { _ in
            isClicked = false
        }
    }

    @ViewBuilder
    private func overlayContent() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colors.getColor(false, colorTheme))
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
                            .scaleEffect(1.7, anchor: .top)
                    }
                }
        }
    }

    public init(cornerRadius: CGFloat = 15, colors: AKeyColors? = nil, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.colors = colors ?? .defaultColors
        self.action = action
        self.content = content
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    AKeyboardBackgroundView {
        KeyBoardSpaceAroundStack(columns: 10, rowSpace: 5, columnSpace: 3) {
            ForEach(0 ..< 50) { index in
                AKeyButtonWithZoom(cornerRadius: 5, colors: .defaultColors) {
                    // print(index)
                } content: {
                    Text(index.description)
                }
            }
        }
    }
    .frame(height: 200)
}
