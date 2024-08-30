import Foundation

public struct ASheetButtonConfig: Codable, Sendable, Hashable {
    public var sheet: SheetType
    public var button: ButtonType
    public var returnButton: ReturnButtonType

    public init(sheet: SheetType, button: ButtonType, returnButton: ReturnButtonType) {
        self.sheet = sheet
        self.button = button
        self.returnButton = returnButton
    }

    public init(_ sheet: SheetType, _ button: ButtonType, return returnButton: ReturnButtonType) {
        self.sheet = sheet
        self.button = button
        self.returnButton = returnButton
    }
}

public extension ASheetButtonConfig {
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

    enum ReturnButtonType: Codable, Sendable, Hashable {
        case closeImage
        case cancel
        case done
    }
}
