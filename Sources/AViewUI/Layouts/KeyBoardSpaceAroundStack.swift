import Foundation
import Numerics
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct KeyBoardSpaceAroundLayout: Layout {
    var columns: Int
    var rowSpace: Double
    var columnSpace: Double

    public func sizeThatFits(proposal: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGSize {
        return CGSize(width: proposal.width ?? 100, height: proposal.height ?? 100)
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        // _口_口_口_
        // columns * 每个项目的width + space * (columns + 1) = fullWidth
        // columns * 每个项目的width + space * columns + space = fullWidth
        // columns * (每个项目的width + space) + space = fullWidth
        // columns * (每个项目的width + space) = fullWidth - space
        // (每个项目的width + space) = (fullWidth - space)/ columns
        // 每个项目的width  = (fullWidth - space)/ columns - space
        let rows = (Double(subviews.count) / Double(columns)).rounded(.up)
        let itemWidth = (bounds.width - columnSpace) / Double(columns) - columnSpace
        let itemHeight = (bounds.height - rowSpace) / rows - rowSpace
        let viewSize = ProposedViewSize(width: itemWidth, height: itemHeight)
        for (index, subview) in subviews.enumerated() {
            let columnIndex = index.remainder(dividingBy: columns, rounding: .towardZero)
            let rowIndex = index.divided(by: columns, rounding: .towardZero)
            let relativeX = Double(columnIndex) * (itemWidth + columnSpace) + columnSpace
            let relativeY = Double(rowIndex) * (itemHeight + rowSpace) + rowSpace
            let position = CGPoint(x: relativeX + bounds.minX,
                                   y: relativeY + bounds.minY)
            subview.place(at: position, anchor: .topLeading, proposal: viewSize)
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct KeyBoardSpaceAroundStack<Content: View>: View {
    var columns: Int
    var rowSpace: Double
    var columnSpace: Double

    var content: () -> Content

    public var body: some View {
        KeyBoardSpaceAroundLayout(columns: columns, rowSpace: rowSpace, columnSpace: columnSpace) {
            content()
        }
    }

    public init(columns: Int, rowSpace: Double, columnSpace: Double, @ViewBuilder content: @escaping () -> Content) {
        self.columns = columns
        self.rowSpace = rowSpace
        self.columnSpace = columnSpace
        self.content = content
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(.green)
        KeyBoardSpaceAroundStack(columns: 4, rowSpace: 10, columnSpace: 10) {
            ForEach(1 ..< 16) { _ in
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
            }
        }
    }
}
