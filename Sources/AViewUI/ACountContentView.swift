import Combine
import Foundation
import SwiftUI

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public struct ACountContentView<Content: View>: View {
    @Binding var time: Double

    var content: () -> Content

    @State private var isShown = false

    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer
            .publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
    }

    @ViewBuilder
    private var conditionalView: some View {
        if isShown {
            content()
        }
    }

    public var body: some View {
        conditionalView
            .transition(.scale)
            .animation(.easeInOut, value: isShown)
            .onReceive(timer) { _ in
                time -= 0.2
                if time > 0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isShown = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShown = false
                    }
                }
            }
    }

    public init(time: Binding<Double>, content: @escaping () -> Content) {
        _time = time
        self.content = content
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
struct CountDownShownView_Previews: PreviewProvider {
    private struct Example: View {
        @State private var time = 5.0

        var body: some View {
            List {
                if time > 0 {
                    ACountContentView(time: $time) {
                        Text(String(time))
                    }
                } else {
                    Button("Countdown Ended") {
                        time = 5
                    }
                }
            }
        }
    }

    static var previews: some View {
        Example()
    }
}
