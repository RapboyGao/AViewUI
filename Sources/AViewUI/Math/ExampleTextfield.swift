import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct ExampleTextfield: View {
    @State private var number: Double?

    var body: some View {
        TextField("Hello", value: $number, format: .number.precision(.significantDigits(0 ... 10)))
        TextField("Hello", value: $number, format: AMathFormatStyle(.number.precision(.significantDigits(0 ... 10))))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview {
    List {
        ExampleTextfield()
    }
}
