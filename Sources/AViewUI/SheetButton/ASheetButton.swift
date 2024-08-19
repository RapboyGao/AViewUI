import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ASheetButton<SomeLabel: View, SomeCover: View>: View {
    @State private var isShown = false

    private var label: () -> SomeLabel
    private var cover: () -> SomeCover
    private var buttonType: ButtonType
    private var sheetType: SheetType

    @ViewBuilder
    private var button: some View {
        switch buttonType {
        case .tapGesture:
            label()
                .foregroundColor(.accentColor)
                .onTapGesture {
                    isShown = true
                }

        case .button:
            Button {
                isShown = true
            } label: {
                label()
            }

        case .menuToEdit:
            Menu {
                Button {
                    isShown = true
                } label: {
                    SwiftUI.Label(I18n.edit, systemImage: "pencil")
                }
            } label: {
                label()
            }

        case .menuToView:
            Menu {
                Button {
                    isShown = true
                } label: {
                    SwiftUI.Label(I18n.view, systemImage: "eye")
                }

            } label: {
                label()
            }
        }
    }

    @ViewBuilder
    private var navStackContent: some View {
        NavigationStack {
            #if os(macOS)
                cover()
            #else
                cover()
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                isShown = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .navigationBarBackButtonHidden()
            #endif
        }
    }

    @ViewBuilder
    private func viewModified<SomeView: View>(view: () -> SomeView) -> some View {
        switch sheetType {
        case .fullScreenCover:
            #if os(macOS)
            view()
                .sheet(isPresented: $isShown) {
                    navStackContent
                }
            #else
            view()
                .fullScreenCover(isPresented: $isShown) {
                    navStackContent
                }
            #endif

        case .sheet:
            #if os(macOS)
            view()
                .sheet(isPresented: $isShown) {
                    navStackContent
                }
            #else
            view()
                .sheet(isPresented: $isShown) {
                    navStackContent
                }
            #endif
        }
    }

    public var body: some View {
        viewModified {
            button
        }
    }

    public init(type sheetType: SheetType, _ buttonType: ButtonType, @ViewBuilder label: @escaping () -> SomeLabel, @ViewBuilder cover: @escaping () -> SomeCover) {
        self.label = label
        self.cover = cover
        self.buttonType = buttonType
        self.sheetType = sheetType
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    List {
        ASheetButton(type: .fullScreenCover, .tapGesture) {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Full Screen")
        }

        ASheetButton(type: .sheet, .tapGesture) {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }

        ASheetButton(type: .fullScreenCover, .menuToView) {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }
    }
}
