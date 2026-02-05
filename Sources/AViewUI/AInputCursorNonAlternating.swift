import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AInputCursorNonAlternating: View {
    var height: Double

    public var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2, height: height)
    }

    public init(height: Double = 20) {
        self.height = height
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *)
#Preview {
    #if os(iOS)
    AInputCursorNonAlternating(height: 20)
    #elseif os(macOS)
    AInputCursorNonAlternating(height: 20)
        .padding()
    #elseif os(tvOS)
    AInputCursorNonAlternating(height: 20)
        .padding()
    #elseif os(watchOS)
    AInputCursorNonAlternating(height: 20)
    #elseif os(visionOS)
    AInputCursorNonAlternating(height: 20)
        .padding()
    #else
    Text("Preview not available")
    #endif
}
