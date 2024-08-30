import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ASheetButton<SomeLabel: View, SomeCover: View>: View {
    @State private var isShown = false

    private var label: () -> SomeLabel
    private var cover: () -> SomeCover
    private var config: ASheetButtonConfig

    private var onSheetClosed: () -> Void

    @ViewBuilder
    private var button: some View {
        switch config.button {
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
                    Label(I18n.edit, systemImage: "pencil")
                }
            } label: {
                label()
            }

        case .menuToView:
            Menu {
                Button {
                    isShown = true
                } label: {
                    Label(I18n.view, systemImage: "eye")
                }

            } label: {
                label()
            }
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
            #if os(macOS)
            cover()
            #else
            cover()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            isShown = false
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
        .onChange(of: isShown) { newValue in
            if !newValue {
                onSheetClosed()
            }
        }
    }

    public init(_ sheetConfig: ASheetButtonConfig, @ViewBuilder label: @escaping () -> SomeLabel, @ViewBuilder cover: @escaping () -> SomeCover, onSheetClosed: @escaping () -> Void = {}) {
        self.config = sheetConfig
        self.label = label
        self.cover = cover
        self.onSheetClosed = onSheetClosed
    }

    public init(getSheetConfig: @escaping () -> ASheetButtonConfig, @ViewBuilder label: @escaping () -> SomeLabel, @ViewBuilder cover: @escaping () -> SomeCover, onSheetClosed: @escaping () -> Void = {}) {
        self.config = getSheetConfig()
        self.label = label
        self.cover = cover
        self.onSheetClosed = onSheetClosed
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
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
}
