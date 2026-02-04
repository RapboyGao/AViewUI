import Foundation
import Numerics
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct KeyBoardSpaceAroundLayout: Layout {
    var columns: Int
    var rowColumns: [Int]
    var specifications: [KeySpecification]
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
        let effectiveRowSlots = effectiveRowColumns
        let rows = max(effectiveRowColumns.count, 1)
        let maxColumns = max(effectiveRowSlots.max() ?? columns, columns)
        let itemWidth = (bounds.width - columnSpace) / Double(maxColumns) - columnSpace
        let itemHeight = (bounds.height - rowSpace) / Double(rows) - rowSpace
        var currentIndex = 0
        let maxRowWidth = Double(maxColumns + 1) * columnSpace + Double(maxColumns) * itemWidth

        let specMap = makeSpecificationMap()

        for (rowIndex, columnsInRow) in effectiveRowColumns.enumerated() {
            guard currentIndex < subviews.count else { break }
            let safeColumns = max(columnsInRow, 1)
            let rowSlots = effectiveRowSlots.indices.contains(rowIndex) ? effectiveRowSlots[rowIndex] : safeColumns
            let remainingSubviews = subviews.count - currentIndex
            let placements = makeRowPlacements(
                rowIndex: rowIndex,
                rowSlots: rowSlots,
                remainingSubviews: remainingSubviews,
                itemWidth: itemWidth,
                baseSpacing: columnSpace,
                maxRowWidth: maxRowWidth,
                specMap: specMap
            )
            let rowWidth = placements.rowWidth
            let rowOffset = max((maxRowWidth - rowWidth) / 2.0, 0)
            var runningX = columnSpace + rowOffset

            for placement in placements.items {
                let subview = subviews[currentIndex]
                let viewSize = ProposedViewSize(width: placement.baseWidth, height: itemHeight)
                let relativeX = runningX + placement.leadingSpacing
                let relativeY = Double(rowIndex) * (itemHeight + rowSpace) + rowSpace
                let position = CGPoint(
                    x: relativeX + bounds.minX,
                    y: relativeY + bounds.minY)
                subview.place(at: position, anchor: .topLeading, proposal: viewSize)
                currentIndex += 1
                runningX += placement.baseWidth + columnSpace + placement.leadingSpacing + placement.trailingSpacing
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

    private struct RowPlacement {
        let leadingSpacing: Double
        let trailingSpacing: Double
        let baseWidth: Double
    }

    private struct RowPlacements {
        let items: [RowPlacement]
        let rowWidth: Double
    }

    private func makeRowPlacements(
        rowIndex: Int,
        rowSlots: Int,
        remainingSubviews: Int,
        itemWidth: Double,
        baseSpacing: Double,
        maxRowWidth: Double,
        specMap: [Int: [Int: KeySpecification]]
    ) -> RowPlacements {
        var items: [RowPlacement] = []
        var columnIndex = 0
        var keysCount = 0
        var totalWidth: Double = baseSpacing
        var totalExtraSpacing: Double = 0

        while columnIndex < rowSlots && keysCount < remainingSubviews {
            let spec = specMap[rowIndex]?[columnIndex]
            let leading = resolveSpacing(
                base: baseSpacing,
                override: spec?.leadingSpacing,
                multiplier: spec?.leadingSpacingMultiplier
            )
            let trailing = resolveSpacing(
                base: baseSpacing,
                override: spec?.trailingSpacing,
                multiplier: spec?.trailingSpacingMultiplier
            )
            let widthMultiplier = max(spec?.widthMultiplier ?? 1, 0)
            let baseWidth =
                itemWidth * widthMultiplier
                + baseSpacing * max(widthMultiplier - 1, 0)
            totalExtraSpacing += (leading + trailing)
            items.append(RowPlacement(leadingSpacing: leading, trailingSpacing: trailing, baseWidth: baseWidth))
            totalWidth += baseWidth + baseSpacing + leading + trailing
            columnIndex += 1
            keysCount += 1
        }

        if totalWidth > maxRowWidth, totalExtraSpacing > 0 {
            let overflow = totalWidth - maxRowWidth
            let scale = max((totalExtraSpacing - overflow) / totalExtraSpacing, 0)
            var scaledItems: [RowPlacement] = []
            var scaledWidth: Double = baseSpacing
            for item in items {
                let scaledLeading = item.leadingSpacing * scale
                let scaledTrailing = item.trailingSpacing * scale
                scaledItems.append(
                    RowPlacement(
                        leadingSpacing: scaledLeading,
                        trailingSpacing: scaledTrailing,
                        baseWidth: item.baseWidth
                    ))
                scaledWidth += item.baseWidth + baseSpacing + scaledLeading + scaledTrailing
            }
            return RowPlacements(items: scaledItems, rowWidth: scaledWidth)
        }

        return RowPlacements(items: items, rowWidth: totalWidth)
    }

    private func makeSpecificationMap() -> [Int: [Int: KeySpecification]] {
        var map: [Int: [Int: KeySpecification]] = [:]
        for spec in specifications {
            guard spec.widthMultiplier > 0 else { continue }
            var rowMap = map[spec.rowIndex] ?? [:]
            if rowMap[spec.columnIndex] == nil {
                rowMap[spec.columnIndex] = spec
            }
            map[spec.rowIndex] = rowMap
        }
        return map
    }

    private func resolveSpacing(base: Double, override: Double?, multiplier: Double?) -> Double {
        if let override {
            return max(override, 0)
        }
        if let multiplier {
            return max(base * multiplier, 0)
        }
        return 0
    }
}

public struct KeySpecification: Hashable {
    public let rowIndex: Int
    public let columnIndex: Int
    public let widthMultiplier: Double
    public let leadingSpacing: Double?
    public let trailingSpacing: Double?
    public let leadingSpacingMultiplier: Double?
    public let trailingSpacingMultiplier: Double?

    public init(
        rowIndex: Int,
        columnIndex: Int,
        widthMultiplier: Double = 1,
        leadingSpacing: Double? = nil,
        trailingSpacing: Double? = nil,
        leadingSpacingMultiplier: Double? = nil,
        trailingSpacingMultiplier: Double? = nil
    ) {
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.widthMultiplier = widthMultiplier
        self.leadingSpacing = leadingSpacing
        self.trailingSpacing = trailingSpacing
        self.leadingSpacingMultiplier = leadingSpacingMultiplier
        self.trailingSpacingMultiplier = trailingSpacingMultiplier
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct KeyBoardSpaceAroundStack<Content: View>: View {
    var columns: Int
    var rowColumns: [Int]
    var specifications: [KeySpecification]
    var rowSpace: Double
    var columnSpace: Double

    var content: () -> Content

    public var body: some View {
        KeyBoardSpaceAroundLayout(
            columns: columns,
            rowColumns: rowColumns,
            specifications: specifications,
            rowSpace: rowSpace,
            columnSpace: columnSpace
        ) {
            content()
        }
    }

    public init(columns: Int, rowSpace: Double, columnSpace: Double, @ViewBuilder content: @escaping () -> Content) {
        self.columns = columns
        self.rowColumns = []
        self.specifications = []
        self.rowSpace = rowSpace
        self.columnSpace = columnSpace
        self.content = content
    }

    public init(rowColumns: [Int], rowSpace: Double, columnSpace: Double, @ViewBuilder content: @escaping () -> Content)
    {
        self.columns = rowColumns.max() ?? 1
        self.rowColumns = rowColumns
        self.specifications = []
        self.rowSpace = rowSpace
        self.columnSpace = columnSpace
        self.content = content
    }

    public init(
        rowColumns: [Int],
        rowSpace: Double,
        columnSpace: Double,
        specifications: [KeySpecification],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.columns = rowColumns.max() ?? 1
        self.rowColumns = rowColumns
        self.specifications = specifications
        self.rowSpace = rowSpace
        self.columnSpace = columnSpace
        self.content = content
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    AKeyboardBackgroundView { _ in
        KeyBoardSpaceAroundStack(
            rowColumns: [10, 9, 9, 5],
            rowSpace: 6,
            columnSpace: 6,
            specifications: [
                .init(rowIndex: 2, columnIndex: 0, widthMultiplier: 1.2, trailingSpacingMultiplier: 2.8),
                .init(rowIndex: 2, columnIndex: 8, widthMultiplier: 1.2, leadingSpacingMultiplier: 2.8),
                .init(rowIndex: 3, columnIndex: 0, widthMultiplier: 2),
                .init(rowIndex: 3, columnIndex: 1, widthMultiplier: 6),
                .init(rowIndex: 3, columnIndex: 2, widthMultiplier: 2),
            ]
        ) {
            let row1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
            let row2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
            let row3 = ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"]
            let row4 = ["123", "space", "return"]
            let keys = row1 + row2 + row3 + row4
            ForEach(keys, id: \.self) { key in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(.white)
                    .overlay(
                        Text(key)
                            .font(.system(size: 14, weight: .medium))
                    )
            }
        }
        .frame(height: 230)
    }

}
