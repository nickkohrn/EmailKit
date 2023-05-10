import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        Text("Your privacy is important. Your data is kept on your device. Everything you type disappears once you tap the send button.")
                    } header: {
                        Label("Privacy", systemImage: "lock.shield.fill")
                    }
                    }
                    Section {
                        Toggle("Haptic Feedback", isOn: viewStore.binding(\.$enableHapticFeedback))
                            .tint(viewStore.selectedAccentColor.color)
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
                            LabeledContent {
                                Label {
                                    Text(viewStore.selectedAccentColor.color.description.localizedCapitalized)
                                } icon: {
                                    Image(systemName: "square.fill")
                                        .imageScale(.large)
                                        .foregroundColor(viewStore.selectedAccentColor.color)
                                }
                            } label: {
                                Text("Accent Color")
                            }
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
            .accentColor(viewStore.selectedAccentColor.color)
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
