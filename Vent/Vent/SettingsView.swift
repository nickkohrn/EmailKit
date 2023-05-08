import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        NavigationLink(
                            destination: IfLetStore(store.scope(
                                state: \.accentColorSelection,
                                action: SettingsFeature.Action.accentColorSelection
                            )) { store in
                                AccentColorSelectionView(store: store)
                            },
                            isActive: viewStore.binding(
                                get: \.isAccentColorSelectionActive,
                                send: { $0 ? .accentColorSelectionTapped : .accentColorSelectionDismissed }
                            )
                        ) {
                            if let selectedAccentColor = viewStore.selectedAccentColor {
                                LabeledContent {
                                    Label {
                                        Text(selectedAccentColor.color.description.localizedCapitalized)
                                    } icon: {
                                        Image(systemName: "square.fill")
                                            .imageScale(.large)
                                            .foregroundColor(selectedAccentColor.color)
                                    }
                                } label: {
                                    Text("Accent Color")
                                }
                            } else {
                                Text("Accent Color")
                            }
                        }
                    }
                    Section {
                        VStack(alignment: .leading) {
                            Toggle("Blur Animation", isOn: viewStore.binding(\.$enableMessageSendBlur))
                            Text("This controls whether a blur animation occurs when simulating a message being sent.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear { viewStore.send(.onAppear) }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { viewStore.send(.dismissButtonActivated) }
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .init(
            initialState: .init(),
            reducer: SettingsFeature()
        ))
    }
}
