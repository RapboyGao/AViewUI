import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ASheetButton<SomeLabel: View, SomeCover: View>: View {
    @State private var isShown = false

    private var label: () -> SomeLabel
    private var cover: () -> SomeCover
    private var config: ASheetButtonConfig

    private var beforeSheetOpen: () -> Void
    private var beforeSheetClose: () -> Void

    private func openSheet() {
        beforeSheetOpen()
        isShown = true
    }

    private func closeSheet() {
        beforeSheetClose()
        isShown = false
    }

    @ViewBuilder
    private var button: some View {
        switch config.button {
        case .tapGesture:
            label()
                .foregroundColor(.accentColor)
                .onTapGesture {
                    openSheet()
                }

        case .button:
            Button {
                openSheet()
            } label: {
                label()
            }

        case .menuToEdit:
            #if os(watchOS)
            Button {
                openSheet()
            } label: {
                label()
            }
            #else
            Menu {
                Button {
                    openSheet()
                } label: {
                    Label(I18n.edit, systemImage: "pencil")
                }
            } label: {
                label()
            }
            #endif

        case .menuToView:
            #if os(watchOS)
            Button {
                openSheet()
            } label: {
                label()
            }
            #else
            Menu {
                Button {
                    openSheet()
                } label: {
                    Label(I18n.view, systemImage: "eye")
                }
            } label: {
                label()
            }
            #endif
        }
    }

    @ViewBuilder
    private var returnButtonLabel: some View {
        switch config.returnButton {
        case .closeImage:
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.gray)
                .font(.system(size: 24))
        case .cancel:
            Text(I18n.cancel)
        case .done:
            Text(I18n.done)
        }
    }

    @ViewBuilder
    private var navStackContent: some View {
        NavigationStack {
            #if os(macOS) || os(watchOS)
            cover()
            #else
            cover()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            closeSheet()
                        } label: {
                            returnButtonLabel
                        }
                    }
                }
                .navigationBarBackButtonHidden()
            #endif
        }
    }

    @ViewBuilder
    private func viewModified<SomeView: View>(view: () -> SomeView) -> some View {
        switch config.sheet {
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

    public init(
        _ sheetConfig: ASheetButtonConfig, @ViewBuilder label: @escaping () -> SomeLabel,
        @ViewBuilder cover: @escaping () -> SomeCover, beforeSheetOpen: @escaping () -> Void = {},
        beforeSheetClose: @escaping () -> Void = {}
    ) {
        self.config = sheetConfig
        self.label = label
        self.cover = cover
        self.beforeSheetOpen = beforeSheetOpen
        self.beforeSheetClose = beforeSheetClose
    }

    public init(
        getSheetConfig: @escaping () -> ASheetButtonConfig,
        @ViewBuilder label: @escaping () -> SomeLabel,
        @ViewBuilder cover: @escaping () -> SomeCover, beforeSheetOpen: @escaping () -> Void = {},
        beforeSheetClose: @escaping () -> Void = {}
    ) {
        self.config = getSheetConfig()
        self.label = label
        self.cover = cover
        self.beforeSheetOpen = beforeSheetOpen
        self.beforeSheetClose = beforeSheetClose
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
#Preview {
    #if os(iOS)
    List {
        ASheetButton {
            ASheetButtonConfig(sheet: .fullScreenCover, button: .button, returnButton: .done)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Full Screen")
        }

        ASheetButton {
            ASheetButtonConfig(.sheet, .tapGesture, return: .cancel)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Full Screen")
        }

        ASheetButton {
            ASheetButtonConfig(.sheet, .menuToEdit, return: .closeImage)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Full Screen")
        }
    }
    #elseif os(macOS)
    List {
        ASheetButton {
            ASheetButtonConfig(sheet: .sheet, button: .button, returnButton: .done)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }

        ASheetButton {
            ASheetButtonConfig(.sheet, .tapGesture, return: .cancel)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }
    }
    .frame(width: 360, height: 300)
    #elseif os(tvOS)
    VStack(spacing: 16) {
        ASheetButton {
            ASheetButtonConfig(.sheet, .button, return: .done)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }
    }
    .padding()
    #elseif os(watchOS)
    VStack(spacing: 8) {
        ASheetButton {
            ASheetButtonConfig(.sheet, .button, return: .done)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }
    }
    .padding(6)
    #elseif os(visionOS)
    VStack(spacing: 16) {
        ASheetButton {
            ASheetButtonConfig(.sheet, .button, return: .done)
        } label: {
            Text(verbatim: "Hello")
        } cover: {
            Text(verbatim: "Sheet")
        }
    }
    .padding()
    .frame(width: 420)
    #else
    Text("Preview not available")
    #endif
}
