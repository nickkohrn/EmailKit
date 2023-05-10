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
                        Label {
                            Text("Privacy")
                        } icon: {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.purple)
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
                    } header: {
                        Label {
                            Text("Appearance")
                        } icon: {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                        }
                    }
                    if viewStore.canMakePayments {
                        Section {
                            ForEach(viewStore.tipProducts) { tip in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(tip.localizedTitle)
                                        Text(tip.localizedDescription)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button {
                                        viewStore.send(.purchasableProductTapped(tip))
                                    } label: {
                                        if case let .purchasing(product) = viewStore.productPurchaseState {
                                            ZStack {
                                                if product == tip {
                                                    Text(tip.localizedPriceString)
                                                        .opacity(0)
                                                        ProgressView()
                                                        .progressViewStyle(.circular)
                                                } else {
                                                    Text(tip.localizedPriceString)
                                                }
                                            }
                                        } else {
                                            Text(tip.localizedPriceString)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .clipShape(Capsule(style: .continuous))
                                    .disabled(viewStore.isMakingPurchase)

                                }
                            }
                        } header: {
                            Label {
                                Text("Leave a Tip")
                            } icon: {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .interactiveDismissDisabled(viewStore.isMakingPurchase)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear { viewStore.send(.onAppear) }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { viewStore.send(.dismissButtonActivated) }
                            .disabled(viewStore.isMakingPurchase)
                    }
                }
            }
            .accentColor(viewStore.selectedAccentColor.color)
            .imageScale(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .init(
            initialState: .init(),
            reducer: SettingsFeature().transformDependency(\.purchasesClient) {
                $0.canMakePayments = { true }
                $0.products = { _ in
                    [.init(
                        localizedDescription: "A cup-of-coffee-sized tip",
                        localizedPriceString: "$0.99",
                        localizedTitle: "Small Tip",
                        productIdentifier: ""
                    )]
                }
            }
        ))
    }
}
