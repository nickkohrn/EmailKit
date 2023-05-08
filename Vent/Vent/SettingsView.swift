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
                    Section {
                        Picker("Interface Style", selection: viewStore.binding(\.$selectedInterfaceStyle)) {
                            ForEach(viewStore.supportedInterfaceStyles) { style in
                                Text(style.title)
                                    .tag(style)
                            }
                        }
                        Text(viewStore.selectedInterfaceStyle.explanation)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Section {
                        if viewStore.selectedInterfaceStyle == .message {
                            Toggle("Blur Animation", isOn: viewStore.binding(\.$enableMessageSendBlur))
                                .tint(viewStore.selectedAccentColor.color)
                            Text("This controls whether a blur animation occurs when the message interface style is used.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    Section {
                        Toggle("Haptic Feedback", isOn: viewStore.binding(\.$enableHapticFeedback))
                            .tint(viewStore.selectedAccentColor.color)
                    }
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
                .animation(.default, value: viewStore.selectedInterfaceStyle)
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
