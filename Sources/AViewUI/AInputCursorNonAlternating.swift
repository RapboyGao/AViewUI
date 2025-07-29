
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

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
#Preview {
    AInputCursorNonAlternating(height: 20)
}
