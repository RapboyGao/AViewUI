import AVFoundation
import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AKeyButtonBGColors: Sendable, Hashable {
    var normal: Color
    var onClick: Color

    public init(_ normal: Color, onClick: Color) {
        self.normal = normal
        self.onClick = onClick
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public struct AKeyButton<Content: View>: View {
    // 定义按钮的操作和内容视图
    var action: () -> Void
    var content: () -> Content

    // 按钮点击时播放的系统音效ID
    var soundId: SystemSoundID = 1104

    // 按钮的背景颜色，可选
    var colors: AKeyButtonBGColors?

    // 按钮的圆角半径
    var cornerRadius: CGFloat

    // 通过环境变量获取当前系统的颜色主题和场景状态
    @Environment(\.colorScheme) private var colorTheme
    @Environment(\.scenePhase) private var scenePhase

    // 用于跟踪按钮是否被点击
    @State private var isClicked = false

    /// 根据按钮点击状态和颜色主题获取背景颜色
    private var backgroundColor: Color {
        if let colors = colors {
            return isClicked ? colors.onClick : colors.normal
        } else {
            let whiteFactor = isClicked ? 0.85 : 0.93
            let darkFactor = isClicked ? 0.3 : 0.15
            return Color(white: colorTheme == .dark ? darkFactor : whiteFactor)
        }
    }

    // 按钮的主体视图
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor) // 使用计算出的背景颜色填充
            content() // 显示传入的内容视图
        }
        .gesture(DragGesture(minimumDistance: 0) // 定义手势，处理点击操作
            .onChanged { _ in
                guard !isClicked else { return }
                AudioServicesPlaySystemSound(soundId)
                isClicked = true
                action()
            }
            .onEnded { _ in
                isClicked = false // 点击结束，重置状态
            })
        .animation(.easeOut(duration: 0.3), value: isClicked) // 添加动画效果
        .onChange(of: scenePhase) { _ in
            isClicked = false // 当场景状态变化时，重置点击状态
        }
    }

    // 初始化方法1：可以指定cornerRadius、colors、action和content
    public init(cornerRadius: CGFloat = 15, colors: AKeyButtonBGColors? = nil, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius // 设置圆角半径
        self.colors = colors // 设置背景颜色
        self.action = action // 设置点击操作
        self.content = content // 设置内容视图
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    KeyBoardSpaceAroundStack(rows: 4, columns: 4, rowSpace: 10, columnSpace: 10) {
        ForEach(0 ..< 15) { index in
            AKeyButton(cornerRadius: 10) {
                // print(index)
            } content: {
                Text(verbatim: index.description)
                    .font(.title)
            }
        }
        AKeyButton(cornerRadius: 10, colors: .init(.red, onClick: .red.opacity(0.5))) {
            // print("AC")
        } content: {
            Text("AC")
                .font(.title)
                .foregroundStyle(.white)
        }
    }
    .frame(height: 400)
}
