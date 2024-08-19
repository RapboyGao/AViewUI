import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
private struct WrappingStackLayout: Layout {
    var vSpacing: CGFloat
    var hSpacing: CGFloat
    var rightToLeft: Bool

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard let proposalWidth = proposal.width else { return .zero }
        var res = CGSize(width: proposalWidth, height: 0)

        var widthThisRow = 0.0
        var maxHeightThisRow = 0.0
        var rowsCount = 0.0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if widthThisRow + size.width + hSpacing > proposalWidth {
                res.height += maxHeightThisRow
                widthThisRow = size.width + hSpacing
                maxHeightThisRow = size.height
                rowsCount += 1
            } else {
                widthThisRow += size.width + hSpacing
                maxHeightThisRow = max(maxHeightThisRow, size.height)
            }
        }
        res.height += maxHeightThisRow + (rowsCount * vSpacing)
        return res
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var position = CGPoint(x: rightToLeft ? bounds.maxX : bounds.minX, y: bounds.minY)
        var maxHeightThisRow: CGFloat = 0.0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            updatePosition(for: subview, in: bounds, at: &position, with: &maxHeightThisRow, size: size)
        }
    }

    private func updatePosition(for subview: LayoutSubviews.Element, in bounds: CGRect, at position: inout CGPoint, with maxHeightThisRow: inout CGFloat, size: CGSize) {
        if rightToLeft {
            if position.x - size.width < bounds.minX {
                position.x = bounds.maxX - size.width
                position.y += maxHeightThisRow + vSpacing
                maxHeightThisRow = size.height
            } else {
                maxHeightThisRow = max(size.height, maxHeightThisRow)
            }
            position.x -= size.width
            subview.place(at: position, proposal: ProposedViewSize.unspecified)
            position.x -= hSpacing
        } else {
            if position.x + size.width > bounds.maxX {
                position.x = bounds.minX
                position.y += maxHeightThisRow + vSpacing
                maxHeightThisRow = size.height
            } else {
                maxHeightThisRow = max(size.height, maxHeightThisRow)
            }
            subview.place(at: position, proposal: ProposedViewSize.unspecified)
            position.x += size.width + hSpacing
        }
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AWrappingStack<Content: View>: View {
    public var vSpacing: CGFloat
    public var hSpacing: CGFloat
    public var rightToLeft = false

    public var content: () -> Content

    public var body: some View {
        WrappingStackLayout(vSpacing: vSpacing, hSpacing: hSpacing, rightToLeft: rightToLeft) {
            content()
        }
    }

    public init(vSpacing: CGFloat = 0, hSpacing: CGFloat = 0, rightToLeft: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.vSpacing = vSpacing
        self.hSpacing = hSpacing
        self.rightToLeft = rightToLeft
        self.content = content
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
struct WrappingStack_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AWrappingStack(vSpacing: 10, hSpacing: 20, rightToLeft: true) {
                ForEach(1 ..< 74) { num in
                    Text("\(num), ")
                }
            }
            .border(.black)
            AWrappingStack {
                ForEach(1 ..< 77) { num in
                    Text("\(num), ")
                }
            }
            .border(.black)
        }
    }
}
