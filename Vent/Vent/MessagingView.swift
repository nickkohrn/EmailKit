import ComposableArchitecture
import Pow
import SwiftUI

struct MessagingView: View {
    let store: StoreOf<MessagingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Group {
                    switch viewStore.selectedInterfaceStyle {
                    case .message: messageLayout(viewStore: viewStore)
                    case .vanish: vanishLayout(viewStore: viewStore)
                    }
                }
                .changeEffect(
                    .feedback(hapticNotification: .success),
                    value: viewStore.isAnimatingInput && viewStore.enableHapticFeedback
                ) // Initiate haptics if animating and haptics enabled
                .navigationTitle("Let It Go")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .onAppear { viewStore.send(.onAppear) }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.settingsButtonActivated)
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.showRoute,
                        send: MessagingFeature.Action.dismissRoute
                    ),
                    content: {
                        IfLetStore(
                            store.scope(
                                state: \.route,
                                action: MessagingFeature.Action.route
                            )
                        ) { routeStore in
                            SwitchStore(routeStore) {
                                CaseLet(
                                    state: /MessagingFeature.State.Route.settings,
                                    action: MessagingFeature.Action.Route.settings
                                ) { store in
                                    SettingsView(store: store)
                                }
                            }
                        }
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func sendButtonImage() -> some View {
        Image(systemName: "paperplane.circle.fill")
            .imageScale(.large)
            .fontWeight(.semibold)
    }

    private func messageRemovalTransition(
        viewStore: ViewStoreOf<MessagingFeature>
    ) -> AnyTransition {
        if viewStore.blurMessageSendAnimation {
            return .movingParts.move(edge: .top).combined(with: .movingParts.blur)
        } else {
            return .movingParts.move(edge: .top)
        }
    }

    @ViewBuilder
    private func messageLayout(
        viewStore: ViewStoreOf<MessagingFeature>
    ) -> some View {
        ZStack {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    TextField(
                        "Write something...",
                        text: viewStore.binding(\.$input),
                        prompt: Text("Write something..."),
                        axis: .vertical
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 0.5)
                    )
                    Button {
                        viewStore.send(.sendInput)
                    } label: {
                        sendButtonImage()
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .tint(viewStore.accentColor.color)
                    .disabled(viewStore.isSendButtonDisabled)
                }
            }
            if viewStore.isAnimatingInput {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        TextField(
                            "Write something...",
                            text: .constant(viewStore.inputToAnimate),
                            prompt: nil,
                            axis: .vertical
                        )
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewStore.accentColor.color)
                        )
                        Button {

                        } label: {
                            sendButtonImage()
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(true)
                        .opacity(0)
                        .padding(.bottom)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .identity,
                        removal: messageRemovalTransition(viewStore: viewStore)
                    )
                )
                .zIndex(1)
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.top)
    }

    @ViewBuilder
    private func vanishLayout(
        viewStore: ViewStoreOf<MessagingFeature>
    ) -> some View {
        VStack {
            Spacer()
            ZStack {
                HStack(alignment: .bottom) {
                    TextField(
                        "Write something...",
                        text: viewStore.binding(\.$input),
                        prompt: Text("Write something..."),
                        axis: .vertical
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 0.5)
                    )
                    Button {
                        viewStore.send(.sendInput)
                    } label: {
                        sendButtonImage()
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .tint(viewStore.accentColor.color)
                    .disabled(viewStore.isSendButtonDisabled)
                }
                if viewStore.isAnimatingInput {
                    HStack(alignment: .bottom) {
                        TextField(
                            "Write something...",
                            text: .constant(viewStore.inputToAnimate),
                            prompt: nil,
                            axis: .vertical
                        )
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewStore.accentColor.color)
                        )
                        Button {

                        } label: {
                            sendButtonImage()
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(true)
                        .opacity(0)
                        .padding(.bottom)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: .movingParts.vanish(viewStore.accentColor.color)
                        )
                    )
                    .zIndex(1)
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagingView(store: .init(
                initialState: .init(),
                reducer: MessagingFeature()
            ))
            .previewDisplayName("Empty")
            
            MessagingView(store: .init(
                initialState: .init(input: "This is a message."),
                reducer: MessagingFeature()
            ))
            .previewDisplayName("Populated")
        }
    }
}
