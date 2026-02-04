import Foundation
import Numerics
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct KeyBoardSpaceAroundLayout: Layout {
    var columns: Int
    var rowColumns: [Int]
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
        let effectiveRowColumns = makeRowColumns(subviewCount: subviews.count)
        let rows = max(effectiveRowColumns.count, 1)
        let maxColumns = max(effectiveRowColumns.max() ?? columns, columns)
        let itemWidth = (bounds.width - columnSpace) / Double(maxColumns) - columnSpace
        let itemHeight = (bounds.height - rowSpace) / Double(rows) - rowSpace
        let viewSize = ProposedViewSize(width: itemWidth, height: itemHeight)
        var currentIndex = 0

        for (rowIndex, columnsInRow) in effectiveRowColumns.enumerated() {
            guard currentIndex < subviews.count else { break }
            let safeColumns = max(columnsInRow, 1)
            let emptySlots = max(maxColumns - safeColumns, 0)
            let rowOffset = (Double(emptySlots) * (itemWidth + columnSpace)) / 2.0
            for columnIndex in 0..<safeColumns {
                guard currentIndex < subviews.count else { break }
                let subview = subviews[currentIndex]
                let relativeX = Double(columnIndex) * (itemWidth + columnSpace) + columnSpace + rowOffset
                let relativeY = Double(rowIndex) * (itemHeight + rowSpace) + rowSpace
                let position = CGPoint(
                    x: relativeX + bounds.minX,
                    y: relativeY + bounds.minY)
                subview.place(at: position, anchor: .topLeading, proposal: viewSize)
                currentIndex += 1
            }
        }
    }

    private func makeRowColumns(subviewCount: Int) -> [Int] {
        if !rowColumns.isEmpty {
            var result = rowColumns
            let total = result.reduce(0, +)
            if total < subviewCount {
                let last = result.last ?? columns
                let remaining = subviewCount - total
                let extraRows = Int(ceil(Double(remaining) / Double(max(last, 1))))
                result.append(contentsOf: Array(repeating: last, count: extraRows))
            }
            return result
        }

        let rows = Int(ceil(Double(subviewCount) / Double(max(columns, 1))))
        return Array(repeating: max(columns, 1), count: max(rows, 1))
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct KeyBoardSpaceAroundStack<Content: View>: View {
    var columns: Int
    var rowColumns: [Int]
    var rowSpace: Double
    var columnSpace: Double

    var content: () -> Content

    public var body: some View {
        KeyBoardSpaceAroundLayout(
            columns: columns,
            rowColumns: rowColumns,
            rowSpace: rowSpace,
            columnSpace: columnSpace
        ) {
            content()
        }
    }

    public init(columns: Int, rowSpace: Double, columnSpace: Double, @ViewBuilder content: @escaping () -> Content) {
        self.columns = columns
        self.rowColumns = []
        self.rowSpace = rowSpace
        self.columnSpace = columnSpace
        self.content = content
    }

    public init(rowColumns: [Int], rowSpace: Double, columnSpace: Double, @ViewBuilder content: @escaping () -> Content)
    {
        self.columns = rowColumns.max() ?? 1
        self.rowColumns = rowColumns
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
        KeyBoardSpaceAroundStack(rowColumns: [3, 4, 5], rowSpace: 10, columnSpace: 10) {
            ForEach(0..<12) { index in
                Rectangle()
                    .foregroundStyle(.red)
            }
        }
    }
}
