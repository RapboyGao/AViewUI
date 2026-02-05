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

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *)
#Preview {
    #if os(iOS)
    AInputCursorView(height: 20)
    #elseif os(macOS)
    AInputCursorView(height: 20)
        .padding()
    #elseif os(tvOS)
    AInputCursorView(height: 20)
        .padding()
    #elseif os(watchOS)
    AInputCursorView(height: 20)
    #elseif os(visionOS)
    AInputCursorView(height: 20)
        .padding()
    #else
    Text("Preview not available")
    #endif
}
