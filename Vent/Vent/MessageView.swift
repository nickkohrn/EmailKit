import ComposableArchitecture
import Pow
import SwiftUI

struct MessageView: View {
    let store: StoreOf<MessageFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
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
                        send: MessageFeature.Action.dismissRoute
                    ),
                    content: {
                        IfLetStore(
                            store.scope(
                                state: \.route,
                                action: MessageFeature.Action.route
                            )
                        ) { routeStore in
                            SwitchStore(routeStore) {
                                CaseLet(
                                    state: /MessageFeature.State.Route.settings,
                                    action: MessageFeature.Action.Route.settings
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
        viewStore: ViewStoreOf<MessageFeature>
    ) -> AnyTransition {
        if viewStore.blurMessageSendAnimation {
            return .movingParts.move(edge: .top).combined(with: .movingParts.blur)
        } else {
            return .movingParts.move(edge: .top)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageView(store: .init(
                initialState: .init(),
                reducer: MessageFeature()
            ))
            .previewDisplayName("Empty")
            
            MessageView(store: .init(
                initialState: .init(input: "This is a message."),
                reducer: MessageFeature()
            ))
            .previewDisplayName("Populated")
        }
    }
}
