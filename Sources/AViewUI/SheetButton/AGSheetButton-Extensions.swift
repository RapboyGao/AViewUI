//
//  File.swift
//
//
//  Created by 高效奕 on 2023/8/29.
//

import Foundation

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension ASheetButton {
    enum ButtonType: Codable, Sendable, Hashable {
        case tapGesture
        case button
        case menuToEdit
        case menuToView
    }

    enum SheetType: Codable, Sendable, Hashable {
        case fullScreenCover
        case sheet
    }
}
