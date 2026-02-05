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

#if os(iOS)
@available(iOS 16, *)
#Preview("iOS") {
    AInputCursorNonAlternating(height: 20)
}
#elseif os(macOS)
@available(macOS 13.0, *)
#Preview("macOS") {
    AInputCursorNonAlternating(height: 20)
        .padding()
}
#elseif os(tvOS)
@available(tvOS 16.0, *)
#Preview("tvOS") {
    AInputCursorNonAlternating(height: 20)
        .padding()
}
#elseif os(watchOS)
@available(watchOS 9.0, *)
#Preview("watchOS") {
    AInputCursorNonAlternating(height: 20)
}
#elseif os(visionOS)
@available(visionOS 1.0, *)
#Preview("visionOS") {
    AInputCursorNonAlternating(height: 20)
        .padding()
}
#endif
