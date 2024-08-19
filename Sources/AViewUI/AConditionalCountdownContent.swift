import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AConditionalCountdownContent<ViewPermanent: View, ViewShort: View>: View {
    @Binding private var timeForCountDown: Double

    var makePermanentView: () -> ViewPermanent
    var makeShortView: () -> ViewShort
    var interval: Double = 0.2

    private var showShortView: Bool {
        timeForCountDown > 0
    }

    public var body: some View {
        Group {
            if showShortView {
                makeShortView()
            } else {
                makePermanentView()
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                timeForCountDown -= interval
            }
        }
    }

    public init(_ timeForCountDown: Binding<Double>, @ViewBuilder default makePermanentView: @escaping () -> ViewPermanent, @ViewBuilder transient makeShortView: @escaping () -> ViewShort, interval: Double = 0.2) {
        _timeForCountDown = timeForCountDown
        self.makePermanentView = makePermanentView
        self.makeShortView = makeShortView
        self.interval = interval
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ConditionalCountdownContent_Previews: PreviewProvider {
    struct Example: View {
        @State private var countDown = 2.0
        var body: some View {
            AConditionalCountdownContent($countDown) {
                Button("hello") {
                    countDown = 2
                }
            } transient: {
                Text("hi")
            }
        }
    }

    static var previews: some View {
        Example()
    }
}
