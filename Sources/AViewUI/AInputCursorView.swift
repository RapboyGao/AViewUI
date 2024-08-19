
import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AInputCursorView: View {
    @State private var isCursorVisible: Bool = true
    var height: Double
    public var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2, height: height)
            .opacity(isCursorVisible ? 1 : 0)
            .animation(
                Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                value: isCursorVisible
            )
            .onAppear {
                isCursorVisible.toggle()
            }
    }

    public init(height: Double = 20) {
        self.height = height
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
#Preview {
    AInputCursorView(height: 20)
}
